package sampleclient;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.Date;

import accessor_one.*;
import accessor_two.*;
import mware_lib.*;


public class SampleClient {

	public static void main(String[] args) throws UnknownHostException {
		ObjectBroker objBroker;
		try {
		// Sequenzdiagram  8
			objBroker = ObjectBroker.init(args[0], Integer.parseInt(args[1]), true);
		} catch (Exception e) {
			System.out.println("Usage: SampleClient <NS_Host> <NS_Port>");
			return;
		}
		// Sequenzdiagram  9 + 10
		NameService nameSvc = objBroker.getNameService();
		
		// Sample Classes resolve
		// Sequenzdiagram  11
		Object a1c1Ref = nameSvc.resolve("a1c1");
		// Sequenzdiagram  15
		accessor_one.ClassOneImplBase a1c1 = accessor_one.ClassOneImplBase.narrowCast(a1c1Ref);
		
		Object a1c2Ref = nameSvc.resolve("a1c2");
		ClassTwoImplBase a1c2 = ClassTwoImplBase.narrowCast(a1c2Ref);
		
		Object a2c1Ref = nameSvc.resolve("a2c1");
		accessor_two.ClassOneImplBase a2c1 = accessor_two.ClassOneImplBase.narrowCast(a2c1Ref);
		
		// Call remotes
		// A1C1
		try {
			// Sequenzdiagram  16
			String s = a1c1.methodOne("hi there!", 567);
			writeLog("a1c1.methodOne", s);
		} catch (accessor_one.SomeException112 e) {
			writeLog("a1c1.methodOne.EX", e.getMessage());
		}
		try {
			String s = a1c1.methodOne("hi there!", 1337);
			writeLog("a1c1.methodOne", s);
		} catch (accessor_one.SomeException112 e) {
			writeLog("a1c1.methodOne.EX", e.getMessage());
		}
		//A1C2	
		try {
			int i = a1c2.methodOne(5);
			writeLog("a1c2.methodOne", Integer.toString(i));
		} catch (accessor_one.SomeException110 e) {
			writeLog("a1c2.methodOne.EX", e.getMessage());
		}
		
		try {
			int i = a1c2.methodOne(1337);
			writeLog("a1c2.methodOne", Integer.toString(i));
		} catch (accessor_one.SomeException110 e) {
			writeLog("a1c2.methodOne.EX", e.getMessage());
		}
		
		try {
			double i = a1c2.methodTwo();
			writeLog("a1c2.methodTwo", Double.toString(i));
		} catch (accessor_one.SomeException112 e) {
			writeLog("a1c2.methodTwo.EX", e.getMessage());
		}
		
		//A2C1
		try {
			double i = a2c1.methodOne("RemoteCall!", 300.1);
			writeLog("a2c1.methodOne", Double.toString(i));
		} catch (accessor_two.SomeException112 e) {
			writeLog("a2c1.methodOne.EX", e.getMessage());
		}
		
		try {
			double i = a2c1.methodOne("RemoteCall!", -300.1);
			writeLog("a2c1.methodOne", Double.toString(i));
		} catch (accessor_two.SomeException112 e) {
			writeLog("a2c1.methodOne.EX", e.getMessage());
		}
		
		try {
			double i = a2c1.methodTwo("RemoteCall!", 0);
			writeLog("a2c1.methodTwo", Double.toString(i));
		} catch (accessor_two.SomeException112 | SomeException304 e) {
			writeLog("a2c1.methodTwo.EX", e.getMessage());
		}
		
		try {
			double i = a2c1.methodTwo("RemoteCall!", -1);
			writeLog("a2c1.methodTwo", Double.toString(i));
		} catch (accessor_two.SomeException112 | SomeException304 e) {
			writeLog("a2c1.methodTwo.EX", e.getMessage());
		}
		
		try {
			double i = a2c1.methodTwo("RemoteCall!", 1);
			writeLog("a2c1.methodTwo", Double.toString(i));
		} catch (accessor_two.SomeException112 | SomeException304 e) {
			writeLog("a2c1.methodTwo.EX", e.getMessage());
		}

		objBroker.shutDown();
	}
	
    private static void writeLog(String classmethod, String message) {
     	 SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss ");
     	 String logEntry = sdf.format(new Date()) + classmethod + " ] " +  message;
     	 System.out.println(logEntry);
    }

}
