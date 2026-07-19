package vn.edu.nlu.fit.be.controller.admin;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import vn.edu.nlu.fit.be.model.Stock;
import vn.edu.nlu.fit.be.repository.StockRepository;

@Controller
public class AdminStockController {

    private final StockRepository stockRepo;

    public AdminStockController(StockRepository stockRepo) {
        this.stockRepo = stockRepo;
    }

    @GetMapping("/admin/stocks")
    public String list(@RequestParam(required = false) String action,
                       @RequestParam(required = false) Integer id, Model model) {
        if ("add".equals(action) || "edit".equals(action)) {
            if ("edit".equals(action) && id != null) {
                model.addAttribute("stock", stockRepo.findById(id).orElse(null));
            }
            return "admin/stock_form";
        }
        model.addAttribute("stocks", stockRepo.findAll(Sort.by("stockId")));
        return "admin/stocks";
    }

    @PostMapping("/admin/stocks")
    public String modify(@RequestParam String action,
                         @RequestParam(required = false) Integer id,
                         @RequestParam(required = false) String name,
                         @RequestParam(required = false) String address) {
        if ("add".equals(action)) {
            Stock s = new Stock();
            s.setStockName(name);
            s.setStockAddress(address);
            stockRepo.save(s);
        } else if ("edit".equals(action) && id != null) {
            Stock s = stockRepo.findById(id).orElse(null);
            if (s != null) {
                s.setStockName(name);
                s.setStockAddress(address);
                stockRepo.save(s);
            }
        } else if ("delete".equals(action) && id != null) {
            stockRepo.deleteById(id);
        }
        return "redirect:/admin/stocks";
    }
}
