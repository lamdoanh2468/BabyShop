package vn.edu.nlu.fit.be.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.nlu.fit.be.model.Product;
import vn.edu.nlu.fit.be.repository.FavoriteRepository;
import vn.edu.nlu.fit.be.repository.ProductRepository;

import java.util.List;

@Service
public class FavoriteProductService {

    private final FavoriteRepository favoriteRepo;
    private final ProductRepository productRepo;

    public FavoriteProductService(FavoriteRepository favoriteRepo, ProductRepository productRepo) {
        this.favoriteRepo = favoriteRepo;
        this.productRepo = productRepo;
    }

    // Toggle: đã thích -> bỏ (false), chưa thích -> thêm (true)
    @Transactional
    public boolean toggle(int accountId, int productId) {
        if (favoriteRepo.exists(accountId, productId)) {
            favoriteRepo.delete(accountId, productId);
            return false;
        }
        favoriteRepo.insert(accountId, productId);
        return true;
    }

    public List<Product> getFavorites(int accountId) {
        return productRepo.findFavoritesByAccountId(accountId);
    }

    public boolean isFavorite(int accountId, int productId) {
        return favoriteRepo.exists(accountId, productId);
    }
}
