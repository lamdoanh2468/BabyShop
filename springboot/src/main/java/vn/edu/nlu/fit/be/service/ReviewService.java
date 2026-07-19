package vn.edu.nlu.fit.be.service;

import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.repository.ReviewRepository;

import java.util.List;
import java.util.Map;

@Service
public class ReviewService {

    private final ReviewRepository reviewRepo;

    public ReviewService(ReviewRepository reviewRepo) {
        this.reviewRepo = reviewRepo;
    }

    public List<Map<String, Object>> getReviewsByProductId(int productId) {
        return reviewRepo.findByProductId(productId);
    }

    public void addReview(int accountId, int productId, String comment) {
        reviewRepo.insert(accountId, productId, comment);
    }
}
