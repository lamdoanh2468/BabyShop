package vn.edu.nlu.fit.be.service;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.model.Voucher;
import vn.edu.nlu.fit.be.repository.VoucherRepository;

import java.util.List;

@Service
public class VoucherService {

    private final VoucherRepository voucherRepo;

    public VoucherService(VoucherRepository voucherRepo) {
        this.voucherRepo = voucherRepo;
    }

    public List<Voucher> getByPage(int pageIndex, int pageSize) {
        if (pageIndex < 1) pageIndex = 1;
        return voucherRepo.findAll(
                PageRequest.of(pageIndex - 1, pageSize, Sort.by(Sort.Direction.DESC, "voucherId"))
        ).getContent();
    }

    public long countAll() {
        return voucherRepo.count();
    }

    public Voucher findById(int id) {
        return voucherRepo.findById(id).orElse(null);
    }

    public Voucher findByCode(String code) {
        return voucherRepo.findByVoucherCode(code).orElse(null);
    }
}
