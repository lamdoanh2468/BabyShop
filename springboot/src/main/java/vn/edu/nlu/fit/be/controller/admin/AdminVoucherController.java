package vn.edu.nlu.fit.be.controller.admin;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Voucher;
import vn.edu.nlu.fit.be.repository.VoucherRepository;

import java.sql.Date;

@Controller
public class AdminVoucherController {

    private final VoucherRepository voucherRepo;

    public AdminVoucherController(VoucherRepository voucherRepo) {
        this.voucherRepo = voucherRepo;
    }

    @GetMapping("/admin/vouchers")
    public String list(@RequestParam(required = false) String action,
                       @RequestParam(required = false) Integer id, Model model) {
        model.addAttribute("vouchers", voucherRepo.findAll(Sort.by("voucherId")));
        if ("edit".equals(action) && id != null) {
            model.addAttribute("voucherToEdit", voucherRepo.findById(id).orElse(null));
        }
        return "admin/vouchers";
    }

    @PostMapping("/admin/vouchers")
    public String modify(@RequestParam String action,
                         @RequestParam(required = false) Integer id,
                         @RequestParam(required = false) String voucherCode,
                         @RequestParam(required = false) String voucherName,
                         @RequestParam(required = false) String voucherImage,
                         @RequestParam(required = false) String description,
                         @RequestParam(required = false) Integer discountAmount,
                         @RequestParam(required = false) String startDate,
                         @RequestParam(required = false) String endDate) {
        if ("delete".equals(action)) {
            if (id != null) voucherRepo.deleteById(id);
        } else if ("edit".equals(action)) {
            if (id != null) {
                Voucher v = voucherRepo.findById(id).orElse(new Voucher());
                v.setVoucherId(id);
                fill(v, voucherCode, voucherName, voucherImage, description, discountAmount, startDate, endDate);
                voucherRepo.save(v);
            }
        } else { // create
            Voucher v = new Voucher();
            fill(v, voucherCode, voucherName, voucherImage, description, discountAmount, startDate, endDate);
            voucherRepo.save(v);
        }
        return "redirect:/admin/vouchers";
    }

    private void fill(Voucher v, String code, String name, String image, String desc,
                      Integer discount, String start, String end) {
        v.setVoucherCode(code);
        v.setVoucherName(name);
        v.setVoucherImage(image);
        v.setDescription(desc);
        if (discount != null) v.setDiscountAmount(discount);
        v.setStartDate(parseDate(start));
        v.setEndDate(parseDate(end));
    }

    private static Date parseDate(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Date.valueOf(s); } catch (IllegalArgumentException e) { return null; }
    }
}
