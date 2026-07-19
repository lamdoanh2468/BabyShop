package vn.edu.nlu.fit.be.controller.admin;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Brand;
import vn.edu.nlu.fit.be.repository.BrandRepository;

@Controller
public class AdminBrandController {

    private final BrandRepository brandRepo;

    public AdminBrandController(BrandRepository brandRepo) {
        this.brandRepo = brandRepo;
    }

    @GetMapping("/admin/brands")
    public String list(@RequestParam(required = false) String action,
                       @RequestParam(required = false) Integer id, Model model) {
        model.addAttribute("brandList", brandRepo.findAll(Sort.by("brandId")));
        if ("edit".equals(action) && id != null) {
            model.addAttribute("brandToEdit", brandRepo.findById(id).orElse(null));
        }
        return "admin/brands";
    }

    @PostMapping("/admin/brands")
    public String modify(@RequestParam String action,
                         @RequestParam(required = false) Integer brandId,
                         @RequestParam(required = false) String brandName,
                         @RequestParam(required = false) String brandLogo,
                         @RequestParam(required = false) String brandDescription) {
        switch (action) {
            case "create" -> {
                Brand b = new Brand();
                b.setBrandName(brandName);
                b.setBrandLogo(brandLogo);
                b.setBrandDescription(brandDescription);
                brandRepo.save(b);
            }
            case "update" -> {
                if (brandId != null) {
                    Brand b = brandRepo.findById(brandId).orElse(null);
                    if (b != null) {
                        b.setBrandName(brandName);
                        b.setBrandLogo(brandLogo);
                        b.setBrandDescription(brandDescription);
                        brandRepo.save(b);
                    }
                }
            }
            case "delete" -> {
                if (brandId != null) brandRepo.deleteById(brandId);
            }
        }
        return "redirect:/admin/brands";
    }
}
