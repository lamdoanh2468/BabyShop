# CLAUDE.md — Migrate BabyShop: JSP/Servlet → Spring Boot + Thymeleaf

Tài liệu này là **playbook migrate** cho dự án BabyShop. Mục tiêu: chuyển toàn bộ web JSP/Servlet
hiện tại sang **Spring Boot 3 + Thymeleaf + Spring Data JPA**, giữ nguyên **database, UI và toàn bộ
tính năng**. Khi làm việc trên repo này, Claude phải theo các quy ước và ánh xạ dưới đây.

> Ngôn ngữ giao tiếp: tiếng Việt. Không đổi schema MySQL. Không đập bỏ UI — port JSP sang Thymeleaf 1:1.

---

## 1. Hiện trạng (nguồn)

- **Package gốc:** `vn.edu.nlu.fit.be`
- **Kiến trúc:** Servlet (`@WebServlet`) → Service (`new` thủ công) → DAO (JDBI 3) → MySQL
- **Quy mô:** 39 controller · 18 service · 40 DAO · 29 model · 8 dto · 6 util · 33 JSP
- **Data access:** JDBI 3.50, `BaseDao` cấp `Jdbi` qua `DBConnect.get()`, map bằng `mapToBean(...)`
- **View:** JSP + JSTL (`c:`, `fmt:`, `fn:`), tiền tệ format bằng `fmt:formatNumber`
- **Auth:** `HttpSession` + BCrypt (thư viện `jbcrypt`)
- **Tính năng đặc thù:** giỏ hàng, đơn hàng, voucher, review, favorite, admin panel,
  đăng nhập Google, OTP qua email (`jakarta.mail`), **ký số đơn hàng** (BouncyCastle `bcpkix`)
- **Đóng gói:** WAR trên Tomcat 11 (JRE 21), chạy bằng Docker, context `/` (ROOT.war)
- **Cấu hình DB:** `db.properties` + override bằng biến môi trường `DB_HOST/DB_PORT/DB_USER/DB_PASSWORD/DB_NAME`

## 2. Đích (target stack)

| Thành phần | Chọn | Ghi chú |
|---|---|---|
| Runtime | **Java 21** | khớp base image `jre21` hiện tại |
| Framework | **Spring Boot 3.3.x** | Jakarta EE 10, hợp Java 21 |
| Web | Spring MVC (`@Controller`) | server-side rendering |
| View | **Thymeleaf** | thay JSP/JSTL |
| ORM | **Spring Data JPA** (Hibernate) | thay JDBI; `ddl-auto=none` |
| Bảo mật | **Spring Security** | thay auth session thủ công (làm ở giai đoạn cuối) |
| Mail | `spring-boot-starter-mail` | thay `jakarta.mail` thủ công |
| Đóng gói | **JAR** (embedded Tomcat) | thay WAR — Docker gọn hơn |

## 3. Nguyên tắc migrate

1. **Lát cắt dọc trước.** KHÔNG migrate cả 39 controller cùng lúc. Làm chạy được một luồng
   đầu-cuối (Home → Product) rồi mới nhân bản. Xem thứ tự ở §11.
2. **DB bất biến.** `spring.jpa.hibernate.ddl-auto=none`. Hibernate KHÔNG được tự sửa schema.
   Entity phải khớp cột hiện có, không đổi tên bảng/cột.
3. **Giữ mật khẩu cũ.** Hash trong bảng `accounts` là BCrypt `$2a$` — `BCryptPasswordEncoder`
   của Spring đọc được y nguyên. Tài khoản cũ vẫn đăng nhập được, KHÔNG cần reset.
4. **Giữ biến môi trường DB.** `application.properties` đọc `${DB_HOST}`… nên `docker-compose`
   hiện tại gần như không phải sửa phần env.
5. **Port UI, đừng vẽ lại.** Mỗi JSP → một template Thymeleaf tương ứng, cùng bố cục/CSS.

## 4. Cấu trúc project mới

```
src/main/java/vn/edu/nlu/fit/be/
  BabyshopApplication.java        # @SpringBootApplication, main()
  controller/                     # @Controller  (từ servlet)
  service/                        # @Service     (constructor injection)
  repository/                     # interface JpaRepository (từ dao/)
  model/  (hoặc entity/)          # @Entity      (từ model/)
  dto/                            # giữ nguyên, dùng cho projection/view
  util/                           # @Component / @Service (email, crypto, otp…)
  config/                         # SecurityConfig, WebConfig, interceptor…
src/main/resources/
  application.properties
  templates/                      # *.html Thymeleaf (từ webapp/*.jsp)
    fragments/                    # header, footer, sidebar dùng chung
  static/                         # css, js, images (từ webapp/)
```

Xoá: `DB/DBConnect.java`, `DB/DBProperties.java`, `dao/BaseDao.java` (Spring lo hết).

---

## 5. Bước 0 — Khởi tạo skeleton

**`pom.xml`** — parent + starters chính:

```xml
<parent>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
  <version>3.3.5</version>
</parent>
<properties><java.version>21</java.version></properties>
<dependencies>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-thymeleaf</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-data-jpa</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-validation</artifactId></dependency>
  <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-mail</artifactId></dependency>
  <dependency><groupId>com.mysql</groupId><artifactId>mysql-connector-j</artifactId><scope>runtime</scope></dependency>
  <!-- ký số đơn hàng: giữ nguyên BouncyCastle -->
  <dependency><groupId>org.bouncycastle</groupId><artifactId>bcpkix-jdk18on</artifactId><version>1.78.1</version></dependency>
  <!-- Spring Security + Thymeleaf security (thêm ở giai đoạn cuối) -->
  <!-- <dependency>…spring-boot-starter-security…</dependency> -->
  <!-- <dependency>…thymeleaf-extras-springsecurity6…</dependency> -->
</dependencies>
<build><plugins>
  <plugin><groupId>org.springframework.boot</groupId><artifactId>spring-boot-maven-plugin</artifactId></plugin>
</plugins></build>
```

> `jbcrypt` bỏ được (dùng `BCryptPasswordEncoder`). `gson`/`jakarta.mail`/`jstl` bỏ dần.

**`BabyshopApplication.java`**

```java
@SpringBootApplication
public class BabyshopApplication {
    public static void main(String[] args) { SpringApplication.run(BabyshopApplication.class, args); }
}
```

**`application.properties`** — thay `DBConnect` + `db.properties`:

```properties
spring.datasource.url=jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/${DB_NAME:db_babyshop}?useUnicode=true&characterEncoding=utf-8&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh
spring.datasource.username=${DB_USER:root}
spring.datasource.password=${DB_PASSWORD:}
spring.jpa.hibernate.ddl-auto=none
spring.jpa.open-in-view=false
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect
spring.thymeleaf.cache=false
server.port=8080
```

Boot thử: `mvn spring-boot:run` — phải khởi động sạch trước khi migrate tiếp.

---

## 6. Model → `@Entity`

Giữ nguyên tên field camelCase, thêm `@Column` map sang cột snake_case (vì JDBI cũ map bằng
alias trong SQL, giờ JPA cần khai báo tường minh).

```java
// TRƯỚC: model/Product.java — POJO thuần
// SAU:
@Entity @Table(name = "products")
public class Product {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id") private int productId;
    @Column(name = "category_id") private int categoryId;
    @Column(name = "brand_id")    private int brandId;
    @Column(name = "product_image")    private String productImage;
    @Column(name = "product_name")     private String productName;
    @Column(name = "product_price")    private int productPrice;
    @Column(name = "product_size")     private String productSize;
    @Column(name = "product_material") private String productMaterial;
    @Column(name = "created_at")       private Timestamp createdAt;
    // getters/setters giữ nguyên
}
```

Quy tắc: cột nullable → kiểu bọc (`Integer`, không `int`). Quan hệ (category_id, brand_id) ban
đầu để field id cho đơn giản; chỉ thêm `@ManyToOne` khi thực sự cần navigate trong template.

## 7. DAO (JDBI) → Repository (Spring Data JPA)

**CRUD cơ bản → có sẵn, khỏi viết:**

```java
public interface ProductRepository extends JpaRepository<Product, Integer> {
    // getProductList()      → findAll()
    // getProductById(id)    → findById(id).orElse(null)
    // getLatestProductsByCategory(catId,20)
    List<Product> findTop20ByCategoryIdOrderByCreatedAtDesc(int categoryId);
}
```

**Query động (`ProductDao.getProductsBy` — lọc category/brand/keyword/sort + phân trang + SUM sold):**
đây là chỗ KHÔNG map được sang derived query. Hai lựa chọn, ưu tiên (a):

(a) **Native query với null-guard** + `Pageable`:

```java
@Query(value = """
    SELECT p.* FROM products p
    LEFT JOIN stock_products sp ON p.product_id = sp.product_id
    LEFT JOIN brands b ON p.brand_id = b.brand_id
    WHERE (:catId IS NULL OR p.category_id = :catId)
      AND (:keyword IS NULL OR LOWER(p.product_name) LIKE LOWER(CONCAT('%',:keyword,'%')))
    GROUP BY p.product_id
    """, nativeQuery = true)
Page<Product> search(@Param("catId") Integer catId,
                     @Param("keyword") String keyword, Pageable pageable);
```
Sort (`price_asc/desc`, `latest`…) đẩy vào `Pageable` bằng `Sort`. Lọc theo danh sách brand
(`IN (...)`) nếu phức tạp thì dùng `@Query` riêng hoặc **Specification** (`JpaSpecificationExecutor`).

(b) Query cực động, nhiều nhánh → `JpaSpecificationExecutor<Product>` + build `Specification`.

> `total_sold` (SUM) không nằm trong entity: trả về `dto/` bằng interface projection hoặc query
> phụ. Giữ `dto` hiện có cho các thống kê (`RevenueByMonth`, `CategoryOrderStat`…).

## 8. Service → `@Service` + constructor injection

```java
// TRƯỚC: new ProductService();  trong service lại new ProductDao();
// SAU:
@Service
public class ProductService {
    private final ProductRepository productRepo;
    public ProductService(ProductRepository productRepo) { this.productRepo = productRepo; }

    public List<Product> getLatestProductsByCategory(int categoryId) {
        return productRepo.findTop20ByCategoryIdOrderByCreatedAtDesc(categoryId);
    }
}
```

Bỏ hết `new XxxService()` / `new XxxDao()`. Mọi phụ thuộc tiêm qua constructor.

## 9. Controller: Servlet → `@Controller`

```java
// TRƯỚC: HomeController extends HttpServlet, doGet → setAttribute → forward("/home.jsp")
// SAU:
@Controller
public class HomeController {
    private final ProductService productService;
    private final CategoryService categoryService;
    public HomeController(ProductService p, CategoryService c) { this.productService=p; this.categoryService=c; }

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("categories",  categoryService.getAllCategories());
        model.addAttribute("NoiThatMoi",  productService.getLatestProductsByCategory(1));
        model.addAttribute("TrangTriMoi", productService.getLatestProductsByCategory(2));
        model.addAttribute("DoChoiMoi",   productService.getLatestProductsByCategory(3));
        return "home"; // → templates/home.html
    }
}
```

Bảng ánh xạ cơ chế Servlet → Spring MVC:

| Servlet | Spring MVC |
|---|---|
| `@WebServlet("/x")` + `doGet` | `@GetMapping("/x")` |
| `doPost` | `@PostMapping("/x")` |
| `req.getParameter("page")` | `@RequestParam(required=false) Integer page` |
| `req.getParameterValues("brand")` | `@RequestParam(required=false) String[] brand` |
| `req.setAttribute("k", v)` | `model.addAttribute("k", v)` |
| `forward("/x.jsp")` | `return "x";` |
| `resp.sendRedirect("/x")` | `return "redirect:/x";` |
| `req.getSession()` | tham số `HttpSession` hoặc `@SessionAttribute` |
| đọc/ghi JSON (`gson`) | trả `@ResponseBody` / `@RestController` |

POST xử lý xong → **redirect** (PRG pattern) để tránh submit lại, dùng
`RedirectAttributes.addFlashAttribute(...)` cho thông báo.

## 10. JSP/JSTL → Thymeleaf

| JSP / JSTL | Thymeleaf |
|---|---|
| `${p.productName}` | `th:text="${p.productName}"` |
| `<c:forEach items="${list}" var="p" varStatus="st">` | `<div th:each="p,st : ${list}">` |
| `${st.index}` / `${st.last}` | y nguyên trong `th:each` (biến `st`) |
| `<c:if test="${empty list}">` | `th:if="${#lists.isEmpty(list)}"` |
| `<c:if test="${not empty x}">` | `th:if="${x != null and !#lists.isEmpty(x)}"` |
| `<c:choose>/<c:when>` | `th:switch` / `th:case` |
| `<c:url value='/cart'/>` , `${pageContext.request.contextPath}/x` | `th:href="@{/cart}"` , `@{/x}` |
| `<fmt:formatNumber value="${p.productPrice}" groupingUsed="true"/>` | `th:text="${#numbers.formatInteger(p.productPrice,0,'POINT')}"` |
| `<c:set var="ctx" .../>` | `th:with="ctx=..."` |
| include header/sidebar | `th:replace="~{fragments/header :: header}"` |

**Ví dụ thật — thẻ sản phẩm trong `home.jsp`:**

```html
<!-- TRƯỚC (JSP) -->
<c:forEach items="${NoiThatMoi}" var="p" varStatus="st">
  <h4 class="product-title">${p.productName}</h4>
  <p class="price"><fmt:formatNumber value="${p.productPrice}" groupingUsed="true"/>đ</p>
  <a href="${ctx}/product-detail?product_id=${p.productId}"><i class="fa-solid fa-eye"></i></a>
</c:forEach>

<!-- SAU (Thymeleaf) -->
<div th:each="p,st : ${NoiThatMoi}">
  <h4 class="product-title" th:text="${p.productName}">Tên</h4>
  <p class="price"><span th:text="${#numbers.formatInteger(p.productPrice,0,'POINT')}">0</span>đ</p>
  <a th:href="@{/product-detail(product_id=${p.productId})}"><i class="fa-solid fa-eye"></i></a>
</div>
```

**Empty state** (đúng bug đã sửa ở bản JSP — giữ nguyên hành vi):

```html
<div th:if="${#lists.isEmpty(NoiThatMoi)}" class="text-center py-8">Chưa có sản phẩm để hiển thị.</div>
```

Lưu ý: Thymeleaf yêu cầu HTML hợp lệ (đóng thẻ đầy đủ) — JSP dễ dãi hơn, khi port phải dọn thẻ hở.

## 11. Static resources & assets

`webapp/css`, `webapp/js`, `webapp/images` (và FontAwesome) → `src/main/resources/static/...`.
Tham chiếu trong template bằng `th:href="@{/css/style.css}"`, `th:src="@{/images/logo.png}"`.
Ảnh sản phẩm: nếu `productImage` là URL tuyệt đối thì để `th:src="${p.productImage}"`.

## 12. Auth / Session / Security

**Mật khẩu:** thay lời gọi `jbcrypt` bằng `BCryptPasswordEncoder` (định dạng tương thích, hash cũ chạy tiếp):

```java
@Bean PasswordEncoder passwordEncoder() { return new BCryptPasswordEncoder(); }
// BCrypt.checkpw(raw, hash)      → passwordEncoder.matches(raw, hash)
// BCrypt.hashpw(raw, gensalt())  → passwordEncoder.encode(raw)
```

**Đăng nhập:** hai giai đoạn —
- *GĐ 1 (nhanh, để app chạy):* giữ mô hình cũ — lưu account vào `HttpSession`, chặn route
  `/admin/**` bằng một `HandlerInterceptor` kiểm tra session.
- *GĐ 2 (điểm cộng CV):* chuyển sang **Spring Security** `formLogin` + `UserDetailsService`
  đọc bảng `accounts`, phân quyền `hasRole('ADMIN')` cho `/admin/**`. Khi bật Security, CSRF mặc
  định bật → form POST cần token; Thymeleaf tự chèn khi có `thymeleaf-extras-springsecurity6`.

**Google login** (`LoginGoogleController`): idiomatic là Spring Security OAuth2 Client, nhưng lớn —
giữ luồng thủ công hiện tại ở GĐ 1, chuyển sau.

## 13. Util & tính năng đặc thù

- `util/EmailUtil`, `OTPUtil` → `@Service`, tiêm `JavaMailSender` (cấu hình `spring.mail.*`).
- `util/CryptoUtil` + **ký số đơn hàng** (BouncyCastle): giữ nguyên logic, bọc thành `@Service`.
  Không đổi thuật toán/khoá — chỉ đổi cách khởi tạo (bean thay vì `new`/static).
- `util/JsonUtil` (gson) → thường bỏ được, để Spring trả JSON qua Jackson (`@ResponseBody`).
- `dto/*` giữ nguyên, dùng cho projection JPA và truyền sang template.

## 14. Docker: WAR → JAR

**`Dockerfile`** (thay bản Tomcat):

```dockerfile
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY target/babyshop-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
```

**`docker-compose.hub.yml`** — service `web` gần như giữ nguyên. Chỉ đổi cách giới hạn heap:
`JAVA_OPTS` (Tomcat) → **`JAVA_TOOL_OPTIONS`** (JVM tự đọc):

```yaml
    environment:
      DB_HOST: mysql
      DB_PORT: 3306
      DB_USER: root
      DB_PASSWORD: ""
      DB_NAME: db_babyshop
      JAVA_TOOL_OPTIONS: "-Xmx300m -Xms128m"   # thay cho JAVA_OPTS
```

Các biến `DB_*` khớp `${...}` trong `application.properties` — không phải sửa. App chạy ở context
`/` sẵn (không cần ROOT.war nữa vì embedded Tomcat mặc định `/`). Tunnel Cloudflare trỏ
`http://localhost:8080` giữ nguyên.

## 15. Thứ tự migrate (checklist lát cắt dọc)

1. [ ] Skeleton boot sạch (§5): pom, `BabyshopApplication`, `application.properties`, Dockerfile-jar.
2. [ ] Entity lát đầu: `Product`, `Category`, `Brand`.
3. [ ] Repository cho 3 entity trên.
4. [ ] Service: `ProductService`, `CategoryService`, `BrandService` (constructor injection).
5. [ ] Controller: `HomeController` (`/`), `ProductListController` (`/product-list`), `ProductDetailController`.
6. [ ] Copy static (css/js/images) sang `resources/static`.
7. [ ] Template: `home.html`, `productList.html`, `productDetail.html` + `fragments/header,footer,sidebar`.
8. [ ] **Chạy & verify:** trang chủ + danh sách sản phẩm ra đúng dữ liệu, không lỗi console.
9. [ ] Nhân bản cho nhóm còn lại, mỗi lần một nhóm: **auth** (login/register/OTP/session) →
       **cart** → **order/checkout** → **profile/favorite/review/voucher** → **admin/**.
10. [ ] Giai đoạn cuối: **Spring Security** (thay session thủ công), **OAuth2 Google**, rà **ký số đơn hàng**.

## 16. Cạm bẫy (đọc trước khi code)

- `ddl-auto` phải là `none` (hoặc `validate`) — tuyệt đối không `update/create`, kẻo Hibernate sửa DB thật.
- `open-in-view=false` → lazy load ngoài transaction sẽ `LazyInitializationException`. Lấy đủ dữ
  liệu trong service, hoặc trả DTO/projection cho template.
- Cột snake_case: bắt buộc `@Column(name=...)` (hoặc set physical naming strategy toàn cục).
- `int` không nhận `null`: cột nullable phải dùng `Integer`.
- Thymeleaf strict HTML: dọn thẻ hở khi port từ JSP.
- Format tiền: `#numbers.formatInteger(x,0,'POINT')` cho ra dấu chấm ngăn nghìn kiểu VN.
- Bật Spring Security → CSRF mặc định bật: mọi form POST phải có token (Thymeleaf tự chèn).
- Giữ đúng tên attribute cũ (`NoiThatMoi`, `TrangTriMoi`, `DoChoiMoi`, `categories`, `products`,
  `soldMap`…) để template port sang đỡ phải đổi biến.

## 17. "Done" cho mỗi controller

Route phản hồi 200 · template render đúng dữ liệu như bản JSP · không lỗi ở console/log ·
POST theo PRG (redirect + flash) · (khi đã bật Security) route được phân quyền đúng.

---

### Build & chạy nhanh

```bash
mvn spring-boot:run                 # dev, cần MySQL ở localhost:3306
mvn clean package                   # ra target/babyshop-0.0.1-SNAPSHOT.jar
docker compose -f docker-compose.hub.yml up -d --build
```
