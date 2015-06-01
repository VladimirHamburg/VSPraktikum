package sampleserver;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Date;

import mware_lib.*;


public class SampleServer {

	public static void main(String[] args) throws UnknownHostException, InterruptedException {
		
		try {
		// Create sample objects
		// Sequenzdiagram  1
		A1SampleClassOne a1c1 = new A1SampleClassOne();
		A1SampleClassTwo a1c2 = new A1SampleClassTwo();
		A2SampleClassOne a2c1 = new A2SampleClassOne();
		
		// Sequenzdiagram  2
		ObjectBroker objBroker = ObjectBroker.init(args[0], Integer.parseInt(args[1]), false);
		
		// Sequenzdiagram  3
		NameService nameSvc = objBroker.getNameService();
		// Sequenzdiagram  5
		nameSvc.rebind((Object) a1c1, "a1c1");
		nameSvc.rebind((Object) a1c2, "a1c2");
		nameSvc.rebind((Object) a2c1, "a2c1");
		
		Thread.sleep(60000);
		objBroker.shutDown();
		} catch (Exception e) {
			System.out.println("Usage: SampleServer <NS_Host> <NS_Port>");
		}
		
		
		
	}
	
	
    private static void writeLog(String classmethod, String message) {
    	 SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss ");
    	 String logEntry = sdf.format(new Date()) + classmethod + " ] " +  message;
    	 System.out.println(logEntry);
    }
}
