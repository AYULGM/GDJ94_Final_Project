import com.health.app.purchase.PurchaseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/purchase")
@RequiredArgsConstructor
public class PurchaseController {

    private final PurchaseService purchaseService;
    private final BranchService branchService;
    private final ProductService productService;

    /** 발주 요청 화면 */
    @GetMapping("/new")
    public String newPurchaseForm(Model model) {

        model.addAttribute("branches", branchService.findAll());
        model.addAttribute("products", productService.findAll());

        return "purchase/new";
    }

    /** 발주 요청 등록 */
    @PostMapping
    public String createPurchase(PurchaseRequestDto dto,
                                 RedirectAttributes redirectAttributes) {

        purchaseService.createPurchase(dto);

        redirectAttributes.addFlashAttribute("message", "발주 요청이 등록되었습니다.");
        return "redirect:/purchase/new";
    }
}
