package mvc_olx.helper;

public class CurrencyFormatter {

	public static String format(double amount) {
		long value = Math.round(amount);
		String str = String.valueOf(value);
		if (str.length() <= 3) {
			return "₹" + str;
		}
		String lastThree = str.substring(str.length() - 3);
		String remaining = str.substring(0, str.length() - 3);
		StringBuilder sb = new StringBuilder();
		int len = remaining.length();
		for (int i = 0; i < len; i++) {
			if (i > 0 && (len - i) % 2 == 0) {
				sb.append(",");
			}
			sb.append(remaining.charAt(i));
		}
		sb.append(",").append(lastThree);
		return "₹" + sb.toString();
	}

}
