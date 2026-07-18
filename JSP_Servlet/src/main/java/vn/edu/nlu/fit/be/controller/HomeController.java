package vn.edu.nlu.fit.be.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import vn.edu.nlu.fit.be.model.Product;
import vn.edu.nlu.fit.be.service.CategoryService;
import vn.edu.nlu.fit.be.service.ProductService;

import java.io.IOException;
import java.util.*;

@WebServlet(name = "HomeController", value = "/home")
public class HomeController extends HttpServlet {
    private final CategoryService categoryService = new CategoryService();

    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Product> interiorProducts = productService.getLatestProductsByCategory(1);
        List<Product> decoratingProducts = productService.getLatestProductsByCategory(2);
        List<Product> toyProducts = productService.getLatestProductsByCategory(3);

        req.setAttribute("categories", categoryService.getAllCategories());
        req.setAttribute("NoiThatMoi", interiorProducts);
        req.setAttribute("TrangTriMoi", decoratingProducts);
        req.setAttribute("DoChoiMoi", toyProducts);
        req.getRequestDispatcher("/home.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}