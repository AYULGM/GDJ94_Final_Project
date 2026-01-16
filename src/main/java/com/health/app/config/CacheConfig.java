package com.health.app.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.concurrent.TimeUnit;

/**
 * Spring Cache 설정 클래스
 *
 * 통계 쿼리 성능 향상을 위한 캐시 설정
 * - Caffeine: 고성능 인메모리 캐시 구현체
 * - TTL: 5분 (통계 데이터 신선도 유지)
 * - 최대 크기: 1000개 엔트리
 */
@Configuration
@EnableCaching
public class CacheConfig {

    /**
     * Caffeine 기반 CacheManager 설정
     *
     * 캐시 종류:
     * - statistics: 통계 조회 결과 (5분 TTL)
     * - options: 지점/카테고리 옵션 (10분 TTL)
     * - settlements: 정산 목록 (3분 TTL)
     */
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager cacheManager = new CaffeineCacheManager(
            "statistics",      // 통계 데이터 캐시
            "options",         // 드롭다운 옵션 캐시
            "settlements"      // 정산 목록 캐시
        );

        cacheManager.setCaffeine(caffeineCacheBuilder());

        return cacheManager;
    }

    /**
     * Caffeine 캐시 빌더 설정
     *
     * - expireAfterWrite: 데이터 쓰기 후 5분 후 자동 만료
     * - maximumSize: 최대 1000개 엔트리 저장
     * - recordStats: 캐시 통계 기록 (히트율, 미스율 등)
     */
    private Caffeine<Object, Object> caffeineCacheBuilder() {
        return Caffeine.newBuilder()
                .expireAfterWrite(5, TimeUnit.MINUTES)  // 5분 후 만료
                .maximumSize(1000)                       // 최대 1000개 엔트리
                .recordStats();                          // 캐시 통계 기록
    }
}
