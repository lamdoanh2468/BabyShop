//Add cart
const cartBtns = document.querySelectorAll(".filter-btn.cart-btn");
cartBtns.forEach((cartBtn) => {
    cartBtn.addEventListener("click", (event) => {
        event.preventDefault();

        // 1. Lấy đường dẫn từ thẻ a
        const url = cartBtn.getAttribute("href");

        // 2. Gửi yêu cầu xuống Server bằng fetch (AJAX)
        fetch(url)
            .then(response => {

                // 1️⃣ CHƯA ĐĂNG NHẬP
                // nếu server redirect về login → response.redirected = true
                if (response.redirected && response.url.includes("login")) {
                    Swal.fire({
                        icon: "warning",
                        title: "Chưa đăng nhập",
                        text: "Bạn cần đăng nhập để sử dụng tính năng này!",
                        showCancelButton: true,
                        confirmButtonText: "Đăng nhập ngay",
                        cancelButtonText: "Hủy"
                    }).then(result => {
                        if (result.isConfirmed) {
                            window.location.href = response.url;
                        }
                    });
                    return;
                }

                // 2️⃣ XỬ LÝ THÀNH CÔNG
                if (response.ok) {
                    Swal.fire({
                        icon: "success",
                        title: "Đã thêm",
                        text: "Sản phẩm đã được thêm vào giỏ hàng.",
                        timer: 1500,
                        showConfirmButton: false,
                    }).then(() => {
                        window.location.href = response.url;
                    });
                    return;
                }

                // 3️⃣ LỖI KHÁC
                throw new Error("Server error");

            })
            .catch(error => {
                console.error(error);
                Swal.fire({
                    icon: "error",
                    title: "Lỗi",
                    text: "Có lỗi xảy ra, vui lòng thử lại sau.",
                });
            });

    })
})
//Add favorite product
const favorBtns = document.querySelectorAll(".filter-btn.favor-btn");
favorBtns.forEach((favorBtn) => {
    favorBtn.addEventListener("click", (event) => {
        event.preventDefault();

        // 1. Lấy đường dẫn từ thẻ a
        const url = favorBtn.getAttribute("href");

        // 2. Gửi yêu cầu xuống Server bằng fetch (AJAX)
        fetch(url)
            .then(response => {

                // 1️⃣ CHƯA ĐĂNG NHẬP
                // nếu server redirect về login → response.redirected = true
                if (response.redirected && response.url.includes("login")) {
                    Swal.fire({
                        icon: "warning",
                        title: "Chưa đăng nhập",
                        text: "Bạn cần đăng nhập để sử dụng tính năng này!",
                        showCancelButton: true,
                        confirmButtonText: "Đăng nhập ngay",
                        cancelButtonText: "Hủy"
                    }).then(result => {
                        if (result.isConfirmed) {
                            window.location.href = response.url;
                        }
                    });
                    return;
                }

                // 2️⃣ XỬ LÝ THÀNH CÔNG
                if (response.ok) {
                    Swal.fire({
                        icon: "success",
                        title: "Đã thêm",
                        text: "Sản phẩm đã được thêm vào danh sách yêu thích.",
                        timer: 1500,
                        showConfirmButton: false,
                    });

                    const icon = favorBtn.querySelector("i");
                    if (icon) {
                        icon.classList.remove("fa-regular");
                        icon.classList.add("fa-solid");
                        icon.style.color = "red";
                    }
                    return;
                }

                // 3️⃣ LỖI KHÁC
                throw new Error("Server error");

            })
            .catch(error => {
                console.error(error);
                Swal.fire({
                    icon: "error",
                    title: "Lỗi",
                    text: "Có lỗi xảy ra, vui lòng thử lại sau.",
                });
            });

    })
})
document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll(".carousel-wrapper").forEach(wrapper => {
        const track = wrapper.querySelector(".carousel-track");
        const grid = wrapper.querySelector(".product-grid");
        const prev = wrapper.querySelector(".carousel-btn.prev");
        const next = wrapper.querySelector(".carousel-btn.next");
        if (!track || !grid || !prev || !next) return;

        // Lấy toàn bộ product-card
        const cards = Array.from(grid.children);
        const cardsPerSlide = 12; // 2 hàng x 6 cột (đúng với CSS .carousel-slide)
        const slideCount = Math.ceil(cards.length / cardsPerSlide);

        // Nếu không đủ 2 trang thì ẩn nút cho khỏi “tưởng không chạy”
        if (slideCount <= 1) {
            prev.style.display = "none";
            next.style.display = "none";
            return;
        }

        // Tạo slide pages
        const slides = [];
        for (let i = 0; i < slideCount; i++) {
            const slide = document.createElement("div");
            slide.className = "carousel-slide";

            cards.slice(i * cardsPerSlide, (i + 1) * cardsPerSlide)
                .forEach(card => slide.appendChild(card));

            slides.push(slide);
        }

        // Replace grid bằng slides
        grid.remove();
        slides.forEach(s => track.appendChild(s));

        let currentIndex = 0;
        const update = () => {
            track.style.transform = `translateX(-${currentIndex * 100}%)`;
        };
        update();

        next.addEventListener("click", (e) => {
            e.preventDefault();
            if (currentIndex < slides.length - 1) currentIndex++;
            update();
        });

        prev.addEventListener("click", (e) => {
            e.preventDefault();
            if (currentIndex > 0) currentIndex--;
            update();
        });
    });
});