package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Profile;

public interface ProfileRepository extends JpaRepository<Profile, Integer> {
}
