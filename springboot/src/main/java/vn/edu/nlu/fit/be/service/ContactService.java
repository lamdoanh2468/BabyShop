package vn.edu.nlu.fit.be.service;

import org.springframework.stereotype.Service;
import vn.edu.nlu.fit.be.model.Contact;
import vn.edu.nlu.fit.be.repository.ContactRepository;

@Service
public class ContactService {

    private final ContactRepository contactRepo;

    public ContactService(ContactRepository contactRepo) {
        this.contactRepo = contactRepo;
    }

    public boolean createContact(int accountId, String fullName, String phone,
                                 String email, String address, String message) {
        Contact c = new Contact();
        c.setAccountId(accountId);
        c.setFullName(fullName);
        c.setPhone(phone);
        c.setEmail(email);
        c.setAddress(address);
        c.setMessage(message);
        contactRepo.save(c);
        return true;
    }
}
