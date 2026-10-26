import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

public class DeleteProductsById {
    public static void main(String[] args) throws Exception {
        String url =
                "jdbc:mysql://localhost:3306/mvc_olx?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Kolkata";
        String user = "root";
        String password = "Rohit@123";

        int[] ids = {6, 7, 8, 9};

        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            conn.setAutoCommit(false);

            int deletedJoinRows = 0;
            try (PreparedStatement ps =
                    conn.prepareStatement("DELETE FROM customer_product WHERE products_id = ?")) {
                for (int id : ids) {
                    ps.setInt(1, id);
                    deletedJoinRows += ps.executeUpdate();
                }
            }

            int deletedProducts = 0;
            try (PreparedStatement ps =
                    conn.prepareStatement("DELETE FROM product WHERE id = ?")) {
                for (int id : ids) {
                    ps.setInt(1, id);
                    deletedProducts += ps.executeUpdate();
                }
            }

            conn.commit();
            System.out.println("Deleted join rows: " + deletedJoinRows);
            System.out.println("Deleted products: " + deletedProducts);
        }
    }
}

