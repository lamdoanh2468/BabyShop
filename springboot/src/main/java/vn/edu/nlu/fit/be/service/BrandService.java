package vn.edu.nlu.fit.be.service;

import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.model.Brand;
import vn.edu.nlu.fit.be.repository.BrandRepository;

import java.util.List;

@Service
public class BrandService {

    private final BrandRepository brandRepo;

    public BrandService(BrandRepository brandRepo) {
        this.brandRepo = brandRepo;
    }

    public List<Brand> getBrands() {
        return brandRepo.findAll(Sort.by("brandId"));
    }

    public Brand getBrandById(int id) {
        return brandRepo.findById(id).orElse(null);
    }
}
