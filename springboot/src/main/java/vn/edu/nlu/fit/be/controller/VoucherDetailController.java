package vn.edu.nlu.fit.be.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.service.VoucherService;

@Controller
public class VoucherDetailController {

    private final VoucherService voucherService;

    public VoucherDetailController(VoucherService voucherService) {
        this.voucherService = voucherService;
    }

    @GetMapping("/voucher-detail")
    public String detail(@RequestParam(required = false) Integer id, Model model) {
        if (id != null) {
            model.addAttribute("voucher", voucherService.findById(id));
        }
        return "voucher_detail"; // template tự hiển thị "không tồn tại" nếu voucher null
    }
}
