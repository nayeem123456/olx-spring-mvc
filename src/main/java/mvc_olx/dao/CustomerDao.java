package mvc_olx.dao;

import java.util.List;

import jakarta.persistence.EntityManager;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import mvc_olx.dto.Customer;
import mvc_olx.dto.Product;

@Component
public class CustomerDao {

	@Autowired
	EntityManager manager;

	public List<Customer> find(long mobile) {
		return manager.createQuery("select x from Customer x where mobile=?1").setParameter(1, mobile).getResultList();
	}

	public void save(Customer customer) {
		manager.getTransaction().begin();
		manager.persist(customer);
		manager.getTransaction().commit();
	}

	public Customer find(int cid) {
		return manager.find(Customer.class, cid);
	}

	public void update(Customer customer) {
		manager.getTransaction().begin();
		manager.merge(customer);
		manager.getTransaction().commit();
	}

	public List<Product> fetchProduct() {
		return manager.createQuery("select x from Product x").getResultList();
	}

	public Product findProduct(int pid) {
		return manager.find(Product.class, pid);
	}

	public List<Product> fetchMyListings(int customerId) {
		return manager.createQuery("select x from Product x where x.sold = ?1")
				.setParameter(1, customerId)
				.getResultList();
	}

	public List<Product> fetchMySalesHistory(int customerId) {
		return manager.createQuery("select x from Product x where x.sold = ?1 and x.status = 'SOLD'")
				.setParameter(1, customerId)
				.getResultList();
	}

	public void deleteProduct(Product product) {
		manager.getTransaction().begin();
		if (!manager.contains(product)) {
			product = manager.merge(product);
		}
		manager.remove(product);
		manager.getTransaction().commit();
	}

	public List<Product> searchProducts(String query, String category, Double minPrice, Double maxPrice, 
                                     String condition, String location, String sortBy, int page, int pageSize) {
		StringBuilder jpql = new StringBuilder("select x from Product x where x.bought = 0 and x.status = 'AVAILABLE'");
		
		if (query != null && !query.trim().isEmpty()) {
			jpql.append(" and (lower(x.name) like :query or lower(x.description) like :query)");
		}
		if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category)) {
			jpql.append(" and x.category = :category");
		}
		if (minPrice != null) {
			jpql.append(" and x.price >= :minPrice");
		}
		if (maxPrice != null) {
			jpql.append(" and x.price <= :maxPrice");
		}
		if (condition != null && !condition.trim().isEmpty() && !"all".equalsIgnoreCase(condition)) {
			jpql.append(" and x.productCondition = :condition");
		}
		if (location != null && !location.trim().isEmpty()) {
			jpql.append(" and lower(x.location) like :location");
		}
		
		// Sorting
		if (sortBy != null && !sortBy.trim().isEmpty()) {
			if ("newest".equalsIgnoreCase(sortBy)) {
				jpql.append(" order by x.createdDate desc, x.id desc");
			} else if ("oldest".equalsIgnoreCase(sortBy)) {
				jpql.append(" order by x.createdDate asc, x.id asc");
			} else if ("price_asc".equalsIgnoreCase(sortBy)) {
				jpql.append(" order by x.price asc");
			} else if ("price_desc".equalsIgnoreCase(sortBy)) {
				jpql.append(" order by x.price desc");
			} else if ("name_asc".equalsIgnoreCase(sortBy)) {
				jpql.append(" order by x.name asc");
			} else if ("name_desc".equalsIgnoreCase(sortBy)) {
				jpql.append(" order by x.name desc");
			} else {
				jpql.append(" order by x.createdDate desc");
			}
		} else {
			jpql.append(" order by x.createdDate desc");
		}
		
		jakarta.persistence.TypedQuery<Product> q = manager.createQuery(jpql.toString(), Product.class);
		
		// Bind parameters
		if (query != null && !query.trim().isEmpty()) {
			q.setParameter("query", "%" + query.trim().toLowerCase() + "%");
		}
		if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category)) {
			q.setParameter("category", category.trim());
		}
		if (minPrice != null) {
			q.setParameter("minPrice", minPrice);
		}
		if (maxPrice != null) {
			q.setParameter("maxPrice", maxPrice);
		}
		if (condition != null && !condition.trim().isEmpty() && !"all".equalsIgnoreCase(condition)) {
			q.setParameter("condition", condition.trim());
		}
		if (location != null && !location.trim().isEmpty()) {
			q.setParameter("location", "%" + location.trim().toLowerCase() + "%");
		}
		
		// Pagination
		q.setFirstResult((page - 1) * pageSize);
		q.setMaxResults(pageSize);
		
		return q.getResultList();
	}

	public long countSearchProducts(String query, String category, Double minPrice, Double maxPrice, 
                                         String condition, String location) {
		StringBuilder jpql = new StringBuilder("select count(x) from Product x where x.bought = 0 and x.status = 'AVAILABLE'");
		
		if (query != null && !query.trim().isEmpty()) {
			jpql.append(" and (lower(x.name) like :query or lower(x.description) like :query)");
		}
		if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category)) {
			jpql.append(" and x.category = :category");
		}
		if (minPrice != null) {
			jpql.append(" and x.price >= :minPrice");
		}
		if (maxPrice != null) {
			jpql.append(" and x.price <= :maxPrice");
		}
		if (condition != null && !condition.trim().isEmpty() && !"all".equalsIgnoreCase(condition)) {
			jpql.append(" and x.productCondition = :condition");
		}
		if (location != null && !location.trim().isEmpty()) {
			jpql.append(" and lower(x.location) like :location");
		}
		
		jakarta.persistence.TypedQuery<Long> q = manager.createQuery(jpql.toString(), Long.class);
		
		// Bind parameters
		if (query != null && !query.trim().isEmpty()) {
			q.setParameter("query", "%" + query.trim().toLowerCase() + "%");
		}
		if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category)) {
			q.setParameter("category", category.trim());
		}
		if (minPrice != null) {
			q.setParameter("minPrice", minPrice);
		}
		if (maxPrice != null) {
			q.setParameter("maxPrice", maxPrice);
		}
		if (condition != null && !condition.trim().isEmpty() && !"all".equalsIgnoreCase(condition)) {
			q.setParameter("condition", condition.trim());
		}
		if (location != null && !location.trim().isEmpty()) {
			q.setParameter("location", "%" + location.trim().toLowerCase() + "%");
		}
		
		return q.getSingleResult();
	}

}
