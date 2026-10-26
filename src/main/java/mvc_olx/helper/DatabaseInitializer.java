package mvc_olx.helper;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import jakarta.persistence.EntityManager;

import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import mvc_olx.dto.Customer;
import mvc_olx.dto.Product;

@Component
public class DatabaseInitializer implements InitializingBean {

	@Autowired
	EntityManager manager;

	@Override
	public void afterPropertiesSet() throws Exception {
		init();
	}

	public void init() {
		// Create the sample-images folders in workspace if not existing
		createSampleImagesFolders();

		// Check if we need to seed database
		long customerCount = 0;
		long productCount = 0;
		try {
			customerCount = (Long) manager.createQuery("select count(c) from Customer c").getSingleResult();
			productCount = (Long) manager.createQuery("select count(p) from Product p").getSingleResult();
		} catch (Exception e) {
			System.err.println("Could not check DB counts. Database may not be initialized yet: " + e.getMessage());
			return;
		}

		// Seed customers if empty
		List<Customer> sellers = new ArrayList<>();
		if (customerCount == 0) {
			manager.getTransaction().begin();

			Customer c1 = new Customer();
			c1.setName("Aarav Sharma");
			c1.setMobile(9876543210L);
			c1.setGender("male");
			c1.setPassword("123456");
			c1.setAge(28);
			c1.setWallet(500000.00);
			c1.setAddress("12th Main, Indiranagar, Bengaluru, Karnataka");
			c1.setDob(Date.valueOf("1998-05-15"));
			manager.persist(c1);
			sellers.add(c1);

			Customer c2 = new Customer();
			c2.setName("Priya Patel");
			c2.setMobile(9876543211L);
			c2.setGender("female");
			c2.setPassword("123456");
			c2.setAge(25);
			c2.setWallet(600000.00);
			c2.setAddress("MG Road, Camp, Pune, Maharashtra");
			c2.setDob(Date.valueOf("2001-08-20"));
			manager.persist(c2);
			sellers.add(c2);

			Customer c3 = new Customer();
			c3.setName("Amit Verma");
			c3.setMobile(9876543212L);
			c3.setGender("male");
			c3.setPassword("123456");
			c3.setAge(31);
			c3.setWallet(450000.00);
			c3.setAddress("Connaught Place, New Delhi");
			c3.setDob(Date.valueOf("1995-12-10"));
			manager.persist(c3);
			sellers.add(c3);

			manager.getTransaction().commit();
		} else {
			sellers = manager.createQuery("select c from Customer c").setMaxResults(3).getResultList();
		}

		// Seed 100 products if product count is low or contains old placeholder images
		boolean hasOldPlaceholders = false;
		if (productCount > 0) {
			try {
				List<Product> sampleProducts = manager.createQuery("select p from Product p", Product.class).setMaxResults(5).getResultList();
				for (Product p : sampleProducts) {
					if ("image/png".equals(p.getImageType())) {
						hasOldPlaceholders = true;
						break;
					}
				}
			} catch (Exception e) {
				// ignore
			}
		}

		if ((productCount != 100 || hasOldPlaceholders) && !sellers.isEmpty()) {
			manager.getTransaction().begin();
			manager.createNativeQuery("delete from Customer_Product").executeUpdate();
			for (Customer s : sellers) {
				if (s.getProducts() != null) {
					s.getProducts().clear();
					manager.merge(s);
				}
			}
			manager.createQuery("delete from Product").executeUpdate();
			manager.getTransaction().commit();
			productCount = 0;
		}

		if (productCount == 0 && !sellers.isEmpty()) {
			manager.getTransaction().begin();

			String[] locations = {
				"Bengaluru, Karnataka", "Hubballi, Karnataka", "Mysuru, Karnataka", "Belagavi, Karnataka",
				"Mumbai, Maharashtra", "Pune, Maharashtra", "Delhi", "Hyderabad, Telangana",
				"Chennai, Tamil Nadu", "Kolkata, West Bengal", "Ahmedabad, Gujarat", "Jaipur, Rajasthan",
				"Lucknow, Uttar Pradesh", "Kochi, Kerala", "Indore, Madhya Pradesh", "Surat, Gujarat",
				"Visakhapatnam, Andhra Pradesh"
			};

			String[] conditions = {"Brand New", "Like New", "Lightly Used", "Heavily Used"};

			// Define product templates per category
			String[] mobiles = {"iPhone 14 Pro", "Samsung Galaxy S23 Ultra", "OnePlus 11 5G", "Google Pixel 7", "Redmi Note 12 Pro", "Vivo V27 Pro", "Realme 11 Pro+", "Nothing Phone (2)", "POCO F5", "IQOO Neo 7"};
			String[] laptops = {"MacBook Air M2", "Dell XPS 13", "HP Pavilion 15", "ASUS ROG Zephyrus", "Lenovo ThinkPad X1", "Acer Aspire 5", "MSI Modern 14", "Xiaomi Notebook Pro", "Gigabyte Aero 16", "Samsung Galaxy Book3"};
			String[] cars = {"Maruti Suzuki Swift", "Hyundai i20 Asta", "Tata Nexon EV", "Mahindra XUV700", "Honda City ZX", "Toyota Glanza", "Kia Seltos", "Skoda Slavia", "Volkswagen Virtus", "MG Hector"};
			String[] bikes = {"Royal Enfield Classic 350", "Honda Activa 6G", "Bajaj Pulsar 150", "TVS Apache RTR 160", "Yamaha R15 V4", "Suzuki Access 125", "KTM Duke 200", "Hero Splendor Plus", "Ola S1 Pro", "Ather 450X"};
			String[] furniture = {"Solid Wood Dining Table", "3-Seater Recliner Sofa", "King Size Storage Bed", "Ergonomic Office Chair", "Modular Wardrobe", "Study Desk with Shelves", "Wooden Bookcase", "Shoe Rack Cabinet", "Bean Bag XXL", "Living Room Coffee Table"};
			String[] electronics = {"Sony WH-1000XM4 Headphones", "Canon EOS 1500D Camera", "JBL Flip 6 Bluetooth Speaker", "Apple Watch Series 8", "Samsung 55\" 4K Smart TV", "GoPro Hero 11 Black", "Amazon Echo Dot 5th Gen", "Sony PlayStation 5", "Fujifilm Instax Mini 11", "iPad Air 5th Gen"};
			String[] fashion = {"Nike Air Max Sneakers", "Fossil Gen 6 Smartwatch", "Ray-Ban Aviator Sunglasses", "Levi's Denim Jacket", "Tommy Hilfiger Leather Wallet", "Samsonite Cabin Luggage", "Casio Edifice Watch", "Adidas Training Shoes", "Zara Trench Coat", "Wildcraft Backpack"};
			String[] books = {"Introduction to Algorithms (CLRS)", "Harry Potter Box Set", "UPSC Civil Services Guide", "The Alchemist - Paulo Coelho", "Atomic Habits - James Clear", "Rich Dad Poor Dad", "Concepts of Physics - HC Verma", "Quantitative Aptitude - RS Aggarwal", "Sapiens - Yuval Noah Harari", "Word Power Made Easy"};
			String[] homeAppliances = {"LG Double Door Refrigerator", "IFB Front Load Washing Machine", "Samsung Solo Microwave", "Daikin 1.5 Ton Split AC", "Philips Air Fryer", "Kent Grand Water Purifier", "Dyson V12 Vacuum Cleaner", "Morphy Richards Oven", "Bajaj 15L Geyser", "Havells Pedestal Fan"};
			String[] sports = {"Yonex Voltric Badminton Racket", "Cosco Premier Football", "SG Scorer Cricket Kit", "Decathlon Yoga Mat 8mm", "Nivia Basketball", "Kookaburra Cricket Ball", "Quechua Hiking Tent", "Vector X Dumbbells Set", "Firefox Mountain Bicycle", "Speedo Swimming Goggles"};
			String[] services = {"AC Servicing & Gas Charging", "Full Home Deep Cleaning", "Professional Wedding Photography", "Interior Design Consultation", "Car Spa & Detail Washing", "Yoga Personal Trainer", "Plumbing & Sanitary Works", "Pest Control Treatment", "Packers and Movers Service", "Web Development Service"};
			String[] others = {"Acoustic Guitar - Yamaha", "Pet Dog Travel Carrier", "Indoor Bonsai Plant Set", "Electric Foot Massager", "Binoculars 10x50", "Digital Weighing Scale", "Adjustable Car Mobile Mount", "Folding Camping Chair", "Wireless Karaoke Microphone", "Paintings for Wall Decor"};

			Random rand = new Random();

			for (int i = 1; i <= 100; i++) {
				Product p = new Product();
				p.setCreatedDate(new Date(System.currentTimeMillis() - (rand.nextInt(30) * 24L * 3600 * 1000))); // Random post date in past 30 days
				p.setStatus(Product.STATUS_AVAILABLE);
				p.setBought(0);

				// Cycle through categories
				String category;
				String name;
				double price;
				String desc;

				int catIndex = i % 12;
				switch (catIndex) {
					case 0:
						category = "Mobiles";
						name = mobiles[rand.nextInt(mobiles.length)] + " (" + i + ")";
						price = 10000 + rand.nextInt(90000);
						desc = "Excellent condition smartphone. 100% battery health, original box and charger included. No scratches.";
						break;
					case 1:
						category = "Laptops";
						name = laptops[rand.nextInt(laptops.length)] + " (" + i + ")";
						price = 25000 + rand.nextInt(120000);
						desc = "High performance laptop with 16GB RAM and SSD storage. Perfect for coding, designing, and office tasks.";
						break;
					case 2:
						category = "Cars";
						name = cars[rand.nextInt(cars.length)] + " (" + i + ")";
						price = 150000 + rand.nextInt(750000);
						desc = "Well-maintained family car. Single owner, regular dealership service, full insurance cover. Great mileage.";
						break;
					case 3:
						category = "Bikes";
						name = bikes[rand.nextInt(bikes.length)] + " (" + i + ")";
						price = 40000 + rand.nextInt(160000);
						desc = "Excellent mileage bike/scooter. Scratchless body, new tires, pollution certificate updated. Smooth ride.";
						break;
					case 4:
						category = "Furniture";
						name = furniture[rand.nextInt(furniture.length)] + " (" + i + ")";
						price = 2000 + rand.nextInt(35000);
						desc = "Premium quality wooden furniture. Sleek design, highly durable, adds a modern touch to your living space.";
						break;
					case 5:
						category = "Electronics";
						name = electronics[rand.nextInt(electronics.length)] + " (" + i + ")";
						price = 1500 + rand.nextInt(55000);
						desc = "Top brand electronic device. Barely used, working flawlessly, under manufacturer warranty. Bill available.";
						break;
					case 6:
						category = "Fashion";
						name = fashion[rand.nextInt(fashion.length)] + " (" + i + ")";
						price = 800 + rand.nextInt(12000);
						desc = "Stylish fashion wear/accessory. Genuine brand, highly comfortable, brand new condition with original tags.";
						break;
					case 7:
						category = "Books";
						name = books[rand.nextInt(books.length)] + " (" + i + ")";
						price = 200 + rand.nextInt(2500);
						desc = "Clean pages, no highlights or pen marks. Best book for reference, exams, or personal leisure reading.";
						break;
					case 8:
						category = "Home Appliances";
						name = homeAppliances[rand.nextInt(homeAppliances.length)] + " (" + i + ")";
						price = 5000 + rand.nextInt(45000);
						desc = "Energy-efficient appliance. Working perfectly, silent operation, cleaned and serviced recently.";
						break;
					case 9:
						category = "Sports";
						name = sports[rand.nextInt(sports.length)] + " (" + i + ")";
						price = 500 + rand.nextInt(18000);
						desc = "Professional sports gear/equipment. Premium build, helps improve performance. Very lightly used.";
						break;
					case 10:
						category = "Services";
						name = services[rand.nextInt(services.length)] + " (" + i + ")";
						price = 499 + rand.nextInt(5000);
						desc = "Professional service at your doorstep. Skilled technicians, affordable pricing, satisfaction guaranteed.";
						break;
					default:
						category = "Others";
						name = others[rand.nextInt(others.length)] + " (" + i + ")";
						price = 300 + rand.nextInt(15000);
						desc = "Useful miscellaneous item. In perfect working condition, selling due to relocation. Deal price.";
						break;
				}

				p.setCategory(category);
				p.setName(name);
				p.setPrice(price);
				p.setDescription(desc);
				p.setProductCondition(conditions[rand.nextInt(conditions.length)]);
				p.setLocation(locations[rand.nextInt(locations.length)]);

				// Fetch or generate image
				byte[] imgBytes = getSampleImageBytes(category, p);
				p.setImage(imgBytes);

				// Distribute ownership among our 3 sellers
				Customer seller = sellers.get(rand.nextInt(sellers.size()));
				p.setSold(seller.getId());

				manager.persist(p);

				// Link product in seller collection
				List<Product> list = seller.getProducts();
				if (list == null) {
					list = new ArrayList<>();
				}
				list.add(p);
				seller.setProducts(list);
				manager.merge(seller);
			}

			manager.getTransaction().commit();
			System.out.println("Successfully seeded database with 100 sample products!");
		}
	}

	private void createSampleImagesFolders() {
		File root = new File("src/main/resources/sample-images");
		if (!root.exists()) {
			root.mkdirs();
		}
		String[] categories = {
			"mobiles", "laptops", "cars", "bikes", "furniture", "electronics",
			"fashion", "books", "home-appliances", "sports", "services", "others"
		};
		for (String cat : categories) {
			File folder = new File(root, cat);
			if (!folder.exists()) {
				folder.mkdirs();
			}
		}
	}

	private byte[] getSampleImageBytes(String category, Product product) {
		String folderName = category.toLowerCase().replace(" ", "-");
		Random rand = new Random();
		int imgNum = rand.nextInt(3) + 1; 
		String resourcePath = "sample-images/" + folderName + "/img_" + imgNum + ".jpg";

		// 1. Try to load from Classpath
		try (java.io.InputStream is = getClass().getClassLoader().getResourceAsStream(resourcePath)) {
			if (is != null) {
				java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
				byte[] buffer = new byte[4096];
				int bytesRead;
				while ((bytesRead = is.read(buffer)) != -1) {
					baos.write(buffer, 0, bytesRead);
				}
				product.setImageType("image/jpeg");
				return baos.toByteArray();
			}
		} catch (IOException e) {
			System.err.println("Error reading classpath resource: " + resourcePath + " - " + e.getMessage());
		}

		// 2. Try to load from physical File System
		File file = new File("src/main/resources/" + resourcePath);
		if (file.exists() && file.isFile()) {
			try (FileInputStream fis = new FileInputStream(file)) {
				byte[] data = new byte[(int) file.length()];
				fis.read(data);
				product.setImageType("image/jpeg");
				return data;
			} catch (IOException e) {
				System.err.println("Error reading file resource: " + file.getAbsolutePath() + " - " + e.getMessage());
			}
		}

		product.setImageType("image/png");
		return generatePlaceholderImage(category);
	}

	private byte[] generatePlaceholderImage(String category) {
		int width = 400;
		int height = 280;
		java.awt.image.BufferedImage img = new java.awt.image.BufferedImage(width, height, java.awt.image.BufferedImage.TYPE_INT_RGB);
		java.awt.Graphics2D g2d = img.createGraphics();

		g2d.setRenderingHint(java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON);

		// Clean modern slate-grey background
		g2d.setColor(new java.awt.Color(241, 245, 249)); 
		g2d.fillRect(0, 0, width, height);

		// Draw card border
		g2d.setColor(new java.awt.Color(226, 232, 240));
		g2d.setStroke(new java.awt.BasicStroke(2));
		g2d.drawRect(10, 10, width - 20, height - 20);

		// Central Text
		g2d.setColor(new java.awt.Color(148, 163, 184)); 
		g2d.setFont(new java.awt.Font("Arial", java.awt.Font.BOLD, 18));
		java.awt.FontMetrics fm = g2d.getFontMetrics();
		String title = "No Image Available";
		int textWidth = fm.stringWidth(title);
		int x = (width - textWidth) / 2;
		int y = (height - fm.getHeight()) / 2 + fm.getAscent();
		g2d.drawString(title, x, y + 20);

		// Camera Icon
		g2d.setFont(new java.awt.Font("Segoe UI Emoji", java.awt.Font.PLAIN, 48));
		String icon = "📷";
		java.awt.FontMetrics fmEmoji = g2d.getFontMetrics();
		int iconWidth = fmEmoji.stringWidth(icon);
		g2d.drawString(icon, (width - iconWidth) / 2, y - 20);

		g2d.dispose();

		java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
		try {
			javax.imageio.ImageIO.write(img, "png", baos);
		} catch (IOException e) {
			// ignore
		}
		return baos.toByteArray();
	}

}
