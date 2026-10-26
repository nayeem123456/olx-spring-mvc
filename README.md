# OLX-SpringMvc

This project is a Spring MVC implementation of an OLX-like platform, allowing users to buy and sell products online.

## Features

- User authentication (signup and login)
- Product listing
- Adding products for sale
- Buying products
- Wallet functionality for transactions

## Technologies Used

- Java
- Spring MVC
- Hibernate
- JSP (JavaServer Pages)
- MySQL
- Maven

## Setup and Installation

1. Install Java 8+ and Maven 3.8+.
2. Clone the repository and open `olx-spring-mvc-jsp-main` in your IDE.
3. Set up MySQL and verify credentials in `src/main/resources/META-INF/persistence.xml`.
4. Build the WAR:
   - `mvn clean package`
5. Deploy `target/mvc_olx.war` on Tomcat 9.
6. Open:
   - `http://localhost:8080/mvc_olx/`

## Local Run Checklist (Windows)

If `mvn` is not recognized in terminal:

1. Install Maven
2. Add Maven `bin` folder to `PATH`
3. Open a new terminal and verify:
   - `mvn -v`

If database connection fails:

1. Ensure MySQL is running on `localhost:3306`
2. Ensure username/password in `persistence.xml` are correct
3. Ensure user has create/alter permissions for database `mvc_olx`

## Project Structure

- `src/main/java/mvc_olx/controller`: Contains the controller classes
- `src/main/java/mvc_olx/dao`: Data Access Object interfaces and implementations
- `src/main/java/mvc_olx/dto`: Data Transfer Objects (Customer, Product)
- `src/main/java/mvc_olx/helper`: Helper classes
- `src/main/webapp/jsp`: JSP views
- `src/main/webapp/WEB-INF`: Configuration files

## Usage

1. Start the application
2. Navigate to the home page
3. Sign up for a new account or log in with existing credentials
4. Browse products, add products for sale, or purchase items

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

