// Hiệu ứng chọn trang
const buttons = document.querySelectorAll(".pagination button");
buttons.forEach(btn => {
    btn.addEventListener("click", () => {
        buttons.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
    });
});
