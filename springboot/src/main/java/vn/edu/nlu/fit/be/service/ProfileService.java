package vn.edu.nlu.fit.be.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.edu.nlu.fit.be.model.Profile;
import vn.edu.nlu.fit.be.repository.ProfileRepository;

import java.sql.Date;

@Service
public class ProfileService {

    private final ProfileRepository profileRepo;

    public ProfileService(ProfileRepository profileRepo) {
        this.profileRepo = profileRepo;
    }

    public Profile findById(int profileId) {
        if (profileId <= 0) return null;
        return profileRepo.findById(profileId).orElse(null);
    }

    /**
     * Cập nhật thông tin cá nhân. Load entity đang quản lý rồi set từng field ->
     * giữ nguyên email & avatar (bản JSP cũ lỡ ghi đè avatar_url = null).
     */
    @Transactional
    public boolean updateProfile(int profileId, String fullName, String phone,
                                 String address, String gender, String birthDate) {
        Profile p = profileRepo.findById(profileId).orElse(null);
        if (p == null) return false;

        p.setFullName(emptyToNull(fullName));
        p.setPhone(emptyToNull(phone));
        p.setAddress(emptyToNull(address));
        p.setGender(emptyToNull(gender));
        p.setBirthDate(parseDate(birthDate));
        // save() không bắt buộc vì entity đang managed, nhưng gọi cho rõ ý định
        profileRepo.save(p);
        return true;
    }

    private static String emptyToNull(String s) {
        return (s == null || s.isBlank()) ? null : s;
    }

    private static Date parseDate(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            return Date.valueOf(s); // yyyy-MM-dd
        } catch (IllegalArgumentException e) {
            return null;
        }
    }
}
