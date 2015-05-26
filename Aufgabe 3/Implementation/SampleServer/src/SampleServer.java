import java.net.UnknownHostException;

import mware_lib.*;


public class SampleServer {

	public static void main(String[] args) throws UnknownHostException, InterruptedException {

		// Create sample objects
		A1SampleClassOne a1c1 = new A1SampleClassOne();
		A1SampleClassTwo a1c2 = new A1SampleClassTwo();
		A2SampleClassOne a2c1 = new A2SampleClassOne();
		
		ObjectBroker objBroker = ObjectBroker.init("localhost", 5655, true);
		
		NameService nameSvc = objBroker.getNameService();
		nameSvc.rebind((Object) a1c1, "a1c1");
		nameSvc.rebind((Object) a1c2, "a1c2");
		nameSvc.rebind((Object) a2c1, "a2c1");
		
		Thread.sleep(30000);
		
		objBroker.shutDown();
	}
}
