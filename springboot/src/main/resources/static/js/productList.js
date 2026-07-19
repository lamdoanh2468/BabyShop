//Back to top page
const backBtn = document.getElementById("backToTop");
const footer = document.getElementById("footer-frame");
window.addEventListener("scroll", () => {
    const footerTop = footer.getBoundingClientRect().top;//get footer's position in page
    const windowHeight = window.innerHeight;
    if (window.scrollY > 400) {
        backBtn.classList.add("show");
    } else {
        backBtn.classList.remove("show");
    }
    if (footerTop < windowHeight) {
        backBtn.style.background = "white";
        backBtn.style.color = "blue";
    } else {
        backBtn.style.background = "#003dd4";
        backBtn.style.color = "white";
    }

});
backBtn.addEventListener("click", () => {
    window.scrollTo({top: 0, behavior: "smooth"});
});
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
// Carousel custom (thay thế Bootstrap)
const carousel = document.getElementById("productListCarousel");
if (carousel) {
    const slidesContainer = carousel.querySelector(".carousel-slides");
    const slides = carousel.querySelectorAll(".carousel-slide");
    const prevBtn = carousel.querySelector(".carousel-control.prev");
    const nextBtn = carousel.querySelector(".carousel-control.next");
    const dots = carousel.querySelectorAll(".carousel-dots .dot");

    let currentIndex = 0;

    const updateCarousel = (index) => {
        const offset = -index * 100;
        slidesContainer.style.transform = `translateX(${offset}%)`;
        slides.forEach((slide, i) => {
            slide.classList.toggle("active", i === index);
        });
        dots.forEach((dot, i) => {
            dot.classList.toggle("active", i === index);
        });
    };

    const goToNext = () => {
        currentIndex = (currentIndex + 1) % slides.length;
        updateCarousel(currentIndex);
    };

    const goToPrev = () => {
        currentIndex = (currentIndex - 1 + slides.length) % slides.length;
        updateCarousel(currentIndex);
    };

    nextBtn.addEventListener("click", goToNext);
    prevBtn.addEventListener("click", goToPrev);

    dots.forEach((dot) => {
        dot.addEventListener("click", () => {
            const index = parseInt(dot.getAttribute("data-index"), 10);
            currentIndex = index;
            updateCarousel(currentIndex);
        });
    });

    // Tự động chạy slide mỗi 5s
    setInterval(goToNext, 5000);
}
document.addEventListener('DOMContentLoaded', () => {
    const filterHeaders = document.querySelectorAll('.filter-header');

    filterHeaders.forEach(header => {
        const group = header.closest('.filter-group');
        if (!group) {
            return;
        }

        const toggleGroup = () => {
            group.classList.toggle('active');
            const expanded = group.classList.contains('active');
            header.setAttribute('aria-expanded', String(expanded));
        };

        header.addEventListener('click', () => {
            toggleGroup();
        });

        header.addEventListener('keydown', (event) => {
            if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                toggleGroup();
            }
        });

        header.setAttribute('aria-expanded', String(group.classList.contains('active')));
    });
});



document.addEventListener("DOMContentLoaded", () => {
    // Lấy tất cả checkbox brand
    const brandCheckboxes = document.querySelectorAll('#brandFilterForm input[type="checkbox"]');

    brandCheckboxes.forEach((checkbox) => {
        checkbox.addEventListener("change", function() {
            // Tìm form cha và submit
            const form = document.getElementById('brandFilterForm');
            if (form) {
                form.submit();
            }
        });
    });
});