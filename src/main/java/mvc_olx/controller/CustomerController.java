package mvc_olx.controller;

import java.io.IOException;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import mvc_olx.dto.Customer;
import mvc_olx.service.CustomerService;

@Controller
public class CustomerController {

	@Autowired
	CustomerService service;

	@RequestMapping("load")
	public ModelAndView load() {
		return service.load();
	}

	@RequestMapping({"", "/", "home", "Home.jsp"})
	public ModelAndView home(HttpSession session) {
		return service.homeLoad(session);
	}

	@PostMapping("signup")
	public ModelAndView signup(@ModelAttribute Customer customer, @RequestParam("bdate") String bdate) {
		return service.signup(customer, bdate);
	}

	@PostMapping("login")
	public ModelAndView login(@RequestParam("cid") int cid, @RequestParam("password") String password, HttpSession session) {
		return service.login(cid, password, session);
	}

	@RequestMapping("logout")
	public ModelAndView logout(HttpSession session) {
		return service.logout(session);
	}

	@PostMapping("addproduct")
	public ModelAndView addProduct(@RequestParam("pname") String pname, @RequestParam("pprice") double pprice,
			@RequestParam("pimage") MultipartFile pimage, @RequestParam("description") String description,
			@RequestParam("category") String category, @RequestParam("condition") String condition,
			@RequestParam("location") String location, HttpSession session) throws IOException {
		return service.addProduct(pname, pprice, pimage, description, category, condition, location, session);
	}

	@RequestMapping("mylistings")
	public ModelAndView myListings(HttpSession session) {
		return service.myListings(session);
	}

	@RequestMapping("productdetails")
	public ModelAndView productDetails(@RequestParam("id") int id, HttpSession session) {
		return service.productDetails(id, session);
	}

	@RequestMapping("editproduct")
	public ModelAndView editProductForm(@RequestParam("id") int id, HttpSession session) {
		return service.editProductForm(id, session);
	}

	@PostMapping("updateproduct")
	public ModelAndView updateProduct(@RequestParam("id") int id, @RequestParam("pname") String pname,
			@RequestParam("pprice") double pprice, @RequestParam("pimage") MultipartFile pimage,
			@RequestParam("description") String description, @RequestParam("category") String category,
			@RequestParam("condition") String condition, @RequestParam("location") String location,
			HttpSession session) throws IOException {
		return service.updateProduct(id, pname, pprice, pimage, description, category, condition, location, session);
	}

	@RequestMapping("deleteproduct")
	public ModelAndView deleteProduct(@RequestParam("id") int id, HttpSession session) {
		return service.deleteProduct(id, session);
	}

	@RequestMapping("markassold")
	public ModelAndView markAsSold(@RequestParam("id") int id, HttpSession session) {
		return service.markAsSold(id, session);
	}

	@RequestMapping("saleshistory")
	public ModelAndView salesHistory(HttpSession session) {
		return service.salesHistory(session);
	}

	@RequestMapping("addmoney")
	public ModelAndView addMoney(@RequestParam("money") double money, HttpSession session) {
		return service.addMoney(money, session);
	}

	@RequestMapping("displayproducts")
	public ModelAndView displayProducts(
			@RequestParam(value = "q",        required = false) String query,
			@RequestParam(value = "category", required = false) String category,
			@RequestParam(value = "minPrice", required = false) String minPrice,
			@RequestParam(value = "maxPrice", required = false) String maxPrice,
			@RequestParam(value = "condition",required = false) String condition,
			@RequestParam(value = "location", required = false) String location,
			@RequestParam(value = "sortBy",   required = false) String sortBy,
			@RequestParam(value = "page",     required = false) String page,
			HttpSession session) {
		return service.displayProducts(query, category, minPrice, maxPrice, condition, location, sortBy, page, session);
	}

	@RequestMapping("wallet")
	public ModelAndView wallet(HttpSession session) {
		return service.wallet(session);
	}

	@RequestMapping("buy")
	public ModelAndView buyProducts(@RequestParam("id") int id, HttpSession session) {
		return service.buyProduct(session, id);
	}

	@RequestMapping("product-image")
	@ResponseBody
	public ResponseEntity<byte[]> productImage(@RequestParam("id") int id) {
		return service.productImage(id);
	}

}
