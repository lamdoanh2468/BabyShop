(function () {
    const hamburger = document.querySelector(".hamburger");
    const mobileMenu = document.querySelector(".mobile-menu");

    if (!hamburger || !mobileMenu) {
        return;
    }

    hamburger.addEventListener("click", function () {
        const expanded = this.getAttribute("aria-expanded") === "true";
        this.setAttribute("aria-expanded", String(!expanded));
        mobileMenu.style.display = expanded ? "none" : "block";
        mobileMenu.setAttribute("aria-hidden", expanded ? "true" : "false");
    });

    document.addEventListener("click", function (e) {
        if (!e.target.closest(".site-header")) {
            mobileMenu.style.display = "none";
            hamburger.setAttribute("aria-expanded", "false");
        }
    });
})();
