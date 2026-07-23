package vn.edu.nlu.fit.be.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.service.VoucherService;

@Controller
public class VoucherListController {

    private static final int PAGE_SIZE = 12;

    private final VoucherService voucherService;

    public VoucherListController(VoucherService voucherService) {
        this.voucherService = voucherService;
    }

    @GetMapping("/voucher-list")
    public String list(@RequestParam(name = "page", defaultValue = "1") int page, Model model) {
        if (page < 1) page = 1;
        long total = voucherService.countAll();
        int totalPage = (int) Math.ceil((double) total / PAGE_SIZE);

        model.addAttribute("vouchers", voucherService.getByPage(page, PAGE_SIZE));
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPage", totalPage);
        return "voucher_list";
    }
}
