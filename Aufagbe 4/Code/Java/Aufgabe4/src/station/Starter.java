package station;

public class Starter {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Receiver newR = new Receiver("225.10.1.2", "lo", 15009);
		newR.run();
	}

}
