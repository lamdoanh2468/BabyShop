package vn.edu.nlu.fit.be.model;

public enum AccountStatus {
    Active,
    UnActive;

    public static AccountStatus from(String s) {
        return AccountStatus.valueOf(s.trim());
    }
}
