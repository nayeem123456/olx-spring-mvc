package mvc_olx.helper;

import jakarta.servlet.MultipartConfigElement;
import jakarta.servlet.ServletRegistration.Dynamic;

import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;

public class MyDispatcherServlet extends AbstractAnnotationConfigDispatcherServletInitializer {

	@Override
	protected Class<?>[] getRootConfigClasses() {
		// TODO Auto-generated method stub
		return null;
	}

	@SuppressWarnings("rawtypes")
	@Override
	protected Class<?>[] getServletConfigClasses() {
		Class[] a = { MyConfiguration.class };
		return a;
	}

	@Override
	protected String[] getServletMappings() {
		String[] a = { "/" };
		return a;
	}

	@Override
	protected void customizeRegistration(Dynamic registration) {
		long maxFileSize = 5L * 1024 * 1024; // 5 MB
		long maxRequestSize = 6L * 1024 * 1024; // 6 MB
		registration.setMultipartConfig(new MultipartConfigElement("", maxFileSize, maxRequestSize, 0));
	}

}
