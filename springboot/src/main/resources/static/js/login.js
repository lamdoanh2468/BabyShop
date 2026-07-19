document.addEventListener("DOMContentLoaded", () => {

    /* ===== Hiện / Ẩn mật khẩu ===== */
    document.querySelectorAll(".toggle-password").forEach(toggle => {
        toggle.addEventListener("click", () => {
            const input = toggle.closest(".password-container").querySelector("input");
            const icon = toggle.querySelector("i");

            if (input.type === "password") {
                input.type = "text";
                icon.classList.replace("fa-eye", "fa-eye-slash");
            } else {
                input.type = "password";
                icon.classList.replace("fa-eye-slash", "fa-eye");
            }
        });
    });

    /* ===== Validate form Register ===== */
    const registerForm = document.getElementById("register-form");
    if (!registerForm) return;

    const emailInput = registerForm.querySelector('input[name="email"]');
    const passwordInput = document.getElementById("register-password");
    const confirmPasswordInput = document.getElementById("confirm-password");
    const errorText = document.getElementById("password-error");

    registerForm.addEventListener("submit", (e) => {
        const email = emailInput ? emailInput.value.trim() : "";
        const password = passwordInput.value;
        const confirmPassword = confirmPasswordInput.value;

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;
        const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;

        if (!emailRegex.test(email)) {
            e.preventDefault();
            errorText.textContent = "Email không hợp lệ.";
            return;
        }

        if (!passwordRegex.test(password)) {
            e.preventDefault();
            errorText.textContent =
                "Mật khẩu phải ≥ 8 ký tự, gồm chữ hoa, chữ thường và số.";
            return;
        }

        if (password !== confirmPassword) {
            e.preventDefault();
            errorText.textContent = "Mật khẩu xác nhận không khớp.";
            return;
        }

        errorText.textContent = "";
    });
});