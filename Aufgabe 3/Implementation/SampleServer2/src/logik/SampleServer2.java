package logik;

import java.net.UnknownHostException;

import mware_lib.NameService;
import mware_lib.ObjectBroker;

public class SampleServer2 {
	

	public static void main(String[] args) throws UnknownHostException {
		
		try {
		// Create sample objects
		// Sequenzdiagram  1
		A1SampleClassOne a1c1 = new A1SampleClassOne();
		A1SampleClassTwo a1c2 = new A1SampleClassTwo();
		
		// Sequenzdiagram  2
		ObjectBroker objBroker = ObjectBroker.init(args[0], Integer.parseInt(args[1]), true);
		
		// Sequenzdiagram  3
		NameService nameSvc = objBroker.getNameService();
		// Sequenzdiagram  5
		nameSvc.rebind((Object) a1c1, "a1c1");
		nameSvc.rebind((Object) a1c2, "a1c2");
		} catch (Exception e) {
			System.out.println("Usage: SampleServer2 <NS_Host> <NS_Port>");
		}
	}

}
