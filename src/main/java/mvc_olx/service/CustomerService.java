package mvc_olx.service;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import mvc_olx.dao.CustomerDao;
import mvc_olx.dto.Customer;
import mvc_olx.dto.Product;

@Component
public class CustomerService {

	@Autowired
	CustomerDao dao;

	public ModelAndView load() {
		ModelAndView andView = new ModelAndView("Signup.jsp");
		andView.addObject("customer", new Customer());

		return andView;
	}

	public ModelAndView signup(Customer customer, String date) {
		ModelAndView andView = new ModelAndView();

		Date dob = Date.valueOf(date);
		int age = Period.between(dob.toLocalDate(), LocalDate.now()).getYears();
		if (age < 18) {
			andView.setViewName("Signup.jsp");
			andView.addObject("customer", customer);
			andView.addObject("msg", "You have to be 18+ to create Account");
		} else {
			if (dao.find(customer.getMobile()).isEmpty()) {
				customer.setAge(age);
				customer.setDob(dob);
				dao.save(customer);
				andView.setViewName("Home.jsp");
				andView.addObject("msg", "Account Created Successfully Your Customer Id is : " + customer.getId());

			} else {
				andView.setViewName("Signup.jsp");
				andView.addObject("customer", customer);
				andView.addObject("msg", "Mobile Number already Exists");
			}
		}

		return andView;
	}

	public ModelAndView login(int cid, String password, HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Customer customer = dao.find(cid);
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "Incorrect Customer Id");
		} else {
			if (customer.getPassword().equals(password)) {
				session.setAttribute("customer", customer);
				andView.setViewName("Home.jsp");
				andView.addObject("msg", "Login Success");
			} else {
				andView.setViewName("Login.jsp");
				andView.addObject("msg", "Incorrect Password");
			}
		}
		return andView;
	}

	public ModelAndView logout(HttpSession session) {
		ModelAndView andView = new ModelAndView("Home.jsp");
		if (session.getAttribute("customer") == null) {
			andView.addObject("msg", "Session Expired");
		} else {
			session.invalidate();
			andView.addObject("msg", "Logout Success");
		}
		return andView;
	}

	private String validateProduct(String name, double price, String description, String category, String condition, String location, MultipartFile image, boolean isImageRequired) {
		if (name == null || name.trim().length() < 2) {
			return "Product name must be at least 2 characters.";
		}
		if (price <= 0) {
			return "Asking price must be greater than 0.";
		}
		if (description == null || description.trim().isEmpty()) {
			return "Description cannot be empty.";
		}
		if (category == null || category.trim().isEmpty()) {
			return "Category cannot be empty.";
		}
		if (condition == null || condition.trim().isEmpty()) {
			return "Condition cannot be empty.";
		}
		if (location == null || location.trim().isEmpty()) {
			return "Location cannot be empty.";
		}
		if (image != null && !image.isEmpty()) {
			if (image.getSize() > 5 * 1024 * 1024) {
				return "Image file size exceeds the limit of 5MB.";
			}
			String contentType = image.getContentType();
			if (contentType == null || (!contentType.equals("image/jpeg") && !contentType.equals("image/png") && !contentType.equals("image/webp") && !contentType.equals("image/gif"))) {
				return "Invalid image format. Supported formats: JPG, PNG, WEBP, GIF.";
			}
		} else if (isImageRequired) {
			return "Please select a product image.";
		}
		return null;
	}

	public ModelAndView addProduct(String pname, double pprice, MultipartFile pimage, String description, String category, String condition, String location, HttpSession session)
			throws IOException {
		Customer customer = (Customer) session.getAttribute("customer");
		ModelAndView andView = new ModelAndView();
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "First Login Then only You can Sell");
			return andView;
		}

		String validationError = validateProduct(pname, pprice, description, category, condition, location, pimage, true);
		if (validationError != null) {
			andView.setViewName("AddProduct.jsp");
			andView.addObject("msg", validationError);
			andView.addObject("pname", pname);
			andView.addObject("pprice", pprice);
			andView.addObject("description", description);
			andView.addObject("category", category);
			andView.addObject("condition", condition);
			andView.addObject("location", location);
			return andView;
		}

		Product product = new Product();

		product.setName(pname);
		product.setPrice(pprice);
		product.setDescription(description);
		product.setCategory(category);
		product.setProductCondition(condition);
		product.setLocation(location);
		product.setSold(customer.getId());
		product.setStatus(Product.STATUS_AVAILABLE);
		product.setCreatedDate(new java.sql.Date(System.currentTimeMillis()));

		byte[] pic = null;
		if (pimage != null && !pimage.isEmpty()) {
			pic = pimage.getBytes();
		}

		product.setImage(pic);
		if (pimage != null) {
			product.setImageType(pimage.getContentType());
		}

		List<Product> list = customer.getProducts();
		if (list == null) {
			list = new ArrayList<Product>();
		}
		list.add(product);

		customer.setProducts(list);

		dao.update(customer);

		andView.setViewName("Home.jsp");
		andView.addObject("msg", "Added Product for Sale");

		return andView;
	}

	public ModelAndView addMoney(double money, HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "First Login Then only You can Add Money");
			return andView;
		}
		customer.setWallet(customer.getWallet() + money);
		dao.update(customer);

		andView.setViewName("Home.jsp");
		andView.addObject("msg", "Added Money in wallet");

		return andView;
	}

	public ModelAndView wallet(HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "First Login Then only You can view Wallet");
			return andView;
		}

		Customer fresh = dao.find(customer.getId());
		if (fresh != null) {
			session.setAttribute("customer", fresh);
		}

		andView.setViewName("Wallet.jsp");
		return andView;
	}

	public static final String[] CATEGORIES = {
		"Mobiles", "Electronics", "Computers & Laptops", "Cars", "Bikes",
		"Furniture", "Fashion", "Books", "Sports", "Home Appliances",
		"Jobs", "Services", "Pets", "Others"
	};

	public static final String[] CONDITIONS = {
		"New", "Like New", "Good", "Fair", "Used"
	};

	public static final int PAGE_SIZE = 12;

	public ModelAndView homeLoad(HttpSession session) {
		ModelAndView andView = new ModelAndView("Home.jsp");
		// Fetch latest 8 products for homepage preview
		List<Product> latestProducts = dao.searchProducts(null, null, null, null, null, null, "newest", 1, 8);
		andView.addObject("latestProducts", latestProducts);
		andView.addObject("categories", CATEGORIES);
		return andView;
	}

	public ModelAndView displayProducts(String query, String category, String minPriceStr, String maxPriceStr,
			String condition, String location, String sortBy, String pageStr, HttpSession session) {

		ModelAndView andView = new ModelAndView();

		// Parse and validate page
		int page = 1;
		if (pageStr != null && !pageStr.trim().isEmpty()) {
			try {
				page = Integer.parseInt(pageStr.trim());
				if (page < 1) page = 1;
			} catch (NumberFormatException e) {
				page = 1;
			}
		}

		// Parse and validate price range
		Double minPrice = null;
		Double maxPrice = null;
		String priceError = null;
		if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
			try {
				minPrice = Double.parseDouble(minPriceStr.trim());
				if (minPrice < 0) { minPrice = null; priceError = "Minimum price cannot be negative."; }
			} catch (NumberFormatException e) {
				priceError = "Invalid minimum price value.";
			}
		}
		if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
			try {
				maxPrice = Double.parseDouble(maxPriceStr.trim());
				if (maxPrice < 0) { maxPrice = null; priceError = "Maximum price cannot be negative."; }
			} catch (NumberFormatException e) {
				priceError = "Invalid maximum price value.";
			}
		}
		if (minPrice != null && maxPrice != null && maxPrice < minPrice) {
			priceError = "Maximum price must be greater than or equal to minimum price.";
			maxPrice = null;
		}

		// Sanitize text inputs
		String cleanQuery    = (query    != null && !query.trim().isEmpty())    ? query.trim()    : null;
		String cleanCategory = (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category.trim())) ? category.trim() : null;
		String cleanCond     = (condition != null && !condition.trim().isEmpty() && !"all".equalsIgnoreCase(condition.trim())) ? condition.trim() : null;
		String cleanLocation = (location  != null && !location.trim().isEmpty())  ? location.trim()  : null;
		String cleanSort     = (sortBy    != null && !sortBy.trim().isEmpty())    ? sortBy.trim()    : "newest";

		// Fetch paginated results from DB
		List<Product> products = dao.searchProducts(cleanQuery, cleanCategory, minPrice, maxPrice, cleanCond, cleanLocation, cleanSort, page, PAGE_SIZE);
		long totalCount        = dao.countSearchProducts(cleanQuery, cleanCategory, minPrice, maxPrice, cleanCond, cleanLocation);
		int totalPages         = (int) Math.ceil((double) totalCount / PAGE_SIZE);
		if (totalPages < 1) totalPages = 1;

		andView.setViewName("Buy.jsp");
		andView.addObject("products", products);
		andView.addObject("totalCount", totalCount);
		andView.addObject("currentPage", page);
		andView.addObject("totalPages", totalPages);
		andView.addObject("categories", CATEGORIES);
		andView.addObject("conditions", CONDITIONS);

		// Preserve filter params for re-rendering form state
		andView.addObject("filterQuery",    cleanQuery    != null ? cleanQuery    : "");
		andView.addObject("filterCategory", cleanCategory != null ? cleanCategory : "");
		andView.addObject("filterMinPrice", minPriceStr   != null ? minPriceStr.trim() : "");
		andView.addObject("filterMaxPrice", maxPriceStr   != null ? maxPriceStr.trim() : "");
		andView.addObject("filterCondition",cleanCond     != null ? cleanCond     : "");
		andView.addObject("filterLocation", cleanLocation != null ? cleanLocation : "");
		andView.addObject("filterSortBy",   cleanSort);

		if (priceError != null) {
			andView.addObject("filterError", priceError);
		}

		return andView;
	}

	public ModelAndView buyProduct(HttpSession session, int id) {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "First Login Then only You can Buy");
		} else {
			Product product = dao.findProduct(id);
			if (product == null || product.getBought() != 0 || !Product.STATUS_AVAILABLE.equals(product.getStatus())) {
				andView.setViewName("Home.jsp");
				andView.addObject("msg", "Product is not available for purchase");
				return andView;
			}
			if (product.getSold() == customer.getId()) {
				andView.setViewName("Home.jsp");
				andView.addObject("msg", "You cannot buy your own product");
				return andView;
			}

			if (customer.getWallet() < product.getPrice()) {
				andView.addObject("msg", "Insufficient Balance");
				andView.setViewName("Home.jsp");
			} else {
				customer.setWallet(customer.getWallet() - product.getPrice());
				Customer customer2 = dao.find(product.getSold());
				if (customer2 == null) {
					andView.setViewName("Home.jsp");
					andView.addObject("msg", "Seller account not found for this product");
					return andView;
				}
				customer2.setWallet(customer2.getWallet() + product.getPrice());

				product.setBought(customer.getId());
				product.setStatus(Product.STATUS_SOLD);
				product.setSoldDate(new java.sql.Date(System.currentTimeMillis()));

				List<Product> products = customer.getProducts();
				products.add(product);

				dao.update(customer);
				dao.update(customer2);
				andView.setViewName("Home.jsp");
				andView.addObject("msg", "Purchased Successfully and will be delivered to " + customer.getAddress());

			}
		}

		return andView;
	}

	public ModelAndView myListings(HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "Please Login first to view your listings.");
			return andView;
		}

		List<Product> list = dao.fetchMyListings(customer.getId());
		andView.setViewName("MyListings.jsp");
		andView.addObject("listings", list);
		return andView;
	}

	public ModelAndView productDetails(int productId, HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Product product = dao.findProduct(productId);
		if (product == null) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "Product not found.");
			return andView;
		}

		Customer seller = dao.find(product.getSold());
		andView.setViewName("ProductDetails.jsp");
		andView.addObject("product", product);
		andView.addObject("seller", seller);
		return andView;
	}

	public ModelAndView editProductForm(int productId, HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "Please login first to edit listings.");
			return andView;
		}

		Product product = dao.findProduct(productId);
		if (product == null) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "Product not found.");
			return andView;
		}

		if (product.getSold() != customer.getId()) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "You do not own this product listing.");
			return andView;
		}

		andView.setViewName("EditProduct.jsp");
		andView.addObject("product", product);
		return andView;
	}

	public ModelAndView updateProduct(int id, String pname, double pprice, MultipartFile pimage, String description, String category, String condition, String location, HttpSession session)
			throws IOException {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "Session expired. Please login.");
			return andView;
		}

		Product product = dao.findProduct(id);
		if (product == null) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "Product not found.");
			return andView;
		}

		if (product.getSold() != customer.getId()) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "Unauthorized action.");
			return andView;
		}

		String validationError = validateProduct(pname, pprice, description, category, condition, location, pimage, false);
		if (validationError != null) {
			andView.setViewName("EditProduct.jsp");
			andView.addObject("msg", validationError);
			andView.addObject("product", product);
			return andView;
		}

		product.setName(pname);
		product.setPrice(pprice);
		product.setDescription(description);
		product.setCategory(category);
		product.setProductCondition(condition);
		product.setLocation(location);
		product.setUpdatedDate(new java.sql.Date(System.currentTimeMillis()));

		if (pimage != null && !pimage.isEmpty()) {
			product.setImage(pimage.getBytes());
			product.setImageType(pimage.getContentType());
		}

		Customer freshCustomer = dao.find(customer.getId());
		for (Product p : freshCustomer.getProducts()) {
			if (p.getId() == id) {
				p.setName(pname);
				p.setPrice(pprice);
				p.setDescription(description);
				p.setCategory(category);
				p.setProductCondition(condition);
				p.setLocation(location);
				p.setUpdatedDate(product.getUpdatedDate());
				if (pimage != null && !pimage.isEmpty()) {
					p.setImage(product.getImage());
					p.setImageType(product.getImageType());
				}
				break;
			}
		}
		dao.update(freshCustomer);
		session.setAttribute("customer", freshCustomer);

		andView.setViewName("mylistings");
		return andView;
	}

	public ModelAndView deleteProduct(int productId, HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "Session expired. Please login.");
			return andView;
		}

		Product product = dao.findProduct(productId);
		if (product == null) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "Product not found.");
			return andView;
		}

		if (product.getSold() != customer.getId()) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "Unauthorized action.");
			return andView;
		}

		if (Product.STATUS_SOLD.equals(product.getStatus())) {
			List<Product> list = dao.fetchMyListings(customer.getId());
			andView.setViewName("MyListings.jsp");
			andView.addObject("listings", list);
			andView.addObject("msg", "Cannot delete a sold product.");
			return andView;
		}

		Customer freshCustomer = dao.find(customer.getId());
		freshCustomer.getProducts().removeIf(p -> p.getId() == productId);
		dao.update(freshCustomer);
		dao.deleteProduct(product);
		session.setAttribute("customer", freshCustomer);

		andView.setViewName("mylistings");
		return andView;
	}

	public ModelAndView markAsSold(int productId, HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "Session expired. Please login.");
			return andView;
		}

		Product product = dao.findProduct(productId);
		if (product == null) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "Product not found.");
			return andView;
		}

		if (product.getSold() != customer.getId()) {
			andView.setViewName("Home.jsp");
			andView.addObject("msg", "Unauthorized action.");
			return andView;
		}

		if (Product.STATUS_SOLD.equals(product.getStatus())) {
			List<Product> list = dao.fetchMyListings(customer.getId());
			andView.setViewName("MyListings.jsp");
			andView.addObject("listings", list);
			andView.addObject("msg", "Product is already marked as sold.");
			return andView;
		}

		product.setStatus(Product.STATUS_SOLD);
		product.setSoldDate(new java.sql.Date(System.currentTimeMillis()));

		Customer freshCustomer = dao.find(customer.getId());
		for (Product p : freshCustomer.getProducts()) {
			if (p.getId() == productId) {
				p.setStatus(Product.STATUS_SOLD);
				p.setSoldDate(product.getSoldDate());
				break;
			}
		}
		dao.update(freshCustomer);
		session.setAttribute("customer", freshCustomer);

		andView.setViewName("mylistings");
		return andView;
	}

	public ModelAndView salesHistory(HttpSession session) {
		ModelAndView andView = new ModelAndView();
		Customer customer = (Customer) session.getAttribute("customer");
		if (customer == null) {
			andView.setViewName("Login.jsp");
			andView.addObject("msg", "Session expired. Please login.");
			return andView;
		}

		List<Product> soldList = dao.fetchMySalesHistory(customer.getId());
		List<String> buyerNames = new ArrayList<>();
		List<String> buyerCustomerIds = new ArrayList<>();

		for (Product p : soldList) {
			if (p.getBought() > 0) {
				Customer buyer = dao.find(p.getBought());
				if (buyer != null) {
					buyerNames.add(buyer.getName());
					buyerCustomerIds.add(String.valueOf(buyer.getId()));
				} else {
					buyerNames.add("N/A");
					buyerCustomerIds.add("N/A");
				}
			} else {
				buyerNames.add("External Sale / Direct");
				buyerCustomerIds.add("N/A");
			}
		}

		andView.setViewName("SalesHistory.jsp");
		andView.addObject("sales", soldList);
		andView.addObject("buyerNames", buyerNames);
		andView.addObject("buyerCustomerIds", buyerCustomerIds);
		return andView;
	}

	public ResponseEntity<byte[]> productImage(int id) {
		Product product = dao.findProduct(id);
		if (product == null || product.getImage() == null || product.getImage().length == 0) {
			return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
		}

		String type = product.getImageType();
		if (type == null || type.trim().isEmpty()) {
			byte[] img = product.getImage();
			if (img.length >= 12
					&& (img[0] & 0xFF) == 0x52 && (img[1] & 0xFF) == 0x49 && (img[2] & 0xFF) == 0x46
					&& (img[3] & 0xFF) == 0x46
					&& (img[8] & 0xFF) == 0x57 && (img[9] & 0xFF) == 0x45 && (img[10] & 0xFF) == 0x42
					&& (img[11] & 0xFF) == 0x50) {
				type = "image/webp";
			} else if (img.length >= 8
					&& (img[0] & 0xFF) == 0x89 && (img[1] & 0xFF) == 0x50 && (img[2] & 0xFF) == 0x4E
					&& (img[3] & 0xFF) == 0x47) {
				type = "image/png";
			} else if (img.length >= 3
					&& (img[0] & 0xFF) == 0xFF && (img[1] & 0xFF) == 0xD8 && (img[2] & 0xFF) == 0xFF) {
				type = "image/jpeg";
			} else if (img.length >= 6) {
				String header = new String(img, 0, 6);
				if (header.startsWith("GIF87a") || header.startsWith("GIF89a")) {
					type = "image/gif";
				}
			}
		}
		MediaType mediaType = MediaType.APPLICATION_OCTET_STREAM;
		if (type != null && !type.trim().isEmpty()) {
			try {
				mediaType = MediaType.parseMediaType(type);
			} catch (Exception ignored) {
				mediaType = MediaType.APPLICATION_OCTET_STREAM;
			}
		}

		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(mediaType);
		headers.setCacheControl(CacheControl.noStore());

		return new ResponseEntity<>(product.getImage(), headers, HttpStatus.OK);
	}

}
