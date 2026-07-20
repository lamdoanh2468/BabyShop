package vn.edu.nlu.fit.be.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.edu.nlu.fit.be.model.Contact;

public interface ContactRepository extends JpaRepository<Contact, Integer> {
}
