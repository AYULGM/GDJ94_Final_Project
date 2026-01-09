package com.health.app.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import com.health.app.security.handler.CustomAuthenticationFailureHandler;
import com.health.app.security.handler.CustomAuthenticationSuccessHandler;
import com.health.app.security.service.CustomUserDetailsService;

import jakarta.servlet.DispatcherType;
import lombok.RequiredArgsConstructor;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final CustomAuthenticationFailureHandler failureHandler;
    private final CustomAuthenticationSuccessHandler successHandler;
    private final CustomUserDetailsService userDetailsService;

    /**
     * 정적자원은 Security FilterChain 자체를 타지 않게 제외
     */
    @Bean
    WebSecurityCustomizer webSecurityCustomizer() {
        return web -> web.ignoring()
            .requestMatchers(
                "/css/**",
                "/js/**",
                "/img/**",
                "/images/**",
                "/vendor/**",
                "/plugins/**",
                "/dist/**",
                "/favicon.ico",
                "/files/**"
            );
    }

    @Bean
    SecurityFilterChain filterChain(HttpSecurity http) throws Exception {

        http
            // (개발 중) 일단 끄고, 로그인 화면 뜨면 다시 켜도 됨
	        .headers(headers -> headers
	                .frameOptions(frame -> frame.sameOrigin())
	            )
            .csrf(csrf -> csrf.disable())

            .authorizeHttpRequests(auth -> auth
                /**
                 * ✅ 핵심: JSP 렌더링은 내부적으로 FORWARD가 발생함.
                 * Spring Security 6에서 FORWARD까지 막으면 /login ↔ /WEB-INF/views/login.jsp 루프로 이어질 수 있음.
                 */
            		
                .dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ERROR).permitAll()

                // 로그인/에러는 누구나 접근
                .requestMatchers(
                        "/login",
                        "/users/join",        // 회원가입 화면
                        "/users/joinProc",    // 회원가입 처리
                        "/users/password/find",
                        "/users/password/findProc",
                        "/error"
                    ).permitAll()

                // 나머지는 인증 필요
                .anyRequest().authenticated()
            )

            .rememberMe(remember -> remember
                    .key("gdj94-remember-me-key") // 임의의 고정 문자열
                    .rememberMeParameter("remember-me") // login.jsp의 checkbox name
                    .tokenValiditySeconds(60 * 60 * 24 * 7) // 7일 지속
                    .userDetailsService(userDetailsService)
                )
            
            .formLogin(form -> form
                .loginPage("/login")              // GET /login
                .loginProcessingUrl("/login")     // POST /login
                .usernameParameter("loginId")
                .passwordParameter("password")
                .successHandler(successHandler)
                .failureHandler(failureHandler)
                .permitAll()
            )

            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID", "remember-me") // 로그아웃할때 세션삭제 뿐만아니라 자동로그인도 해제되게끔
            );

        return http.build();
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
