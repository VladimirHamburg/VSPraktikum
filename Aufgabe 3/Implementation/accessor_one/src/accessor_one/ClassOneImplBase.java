package accessor_one;

import java.text.SimpleDateFormat;
import java.util.Date;

import mware_lib.Invokeable;

public abstract class ClassOneImplBase implements Invokeable {
	public abstract String methodOne(String param1, int param2) throws SomeException112;
	public static ClassOneImplBase narrowCast(Object rawObjectRef) {
		return new ClassOneImpl((String[])rawObjectRef);
	}
	
	public String Invoke(String[] splitData) {
    	String methodName = splitData[1];
    	String param1 = splitData[2];
    	int param2 = Integer.parseInt(splitData[3]);
    	
    	if (methodName.equals("methodOne")) {
	    	try {
	    		// Sequenzdiagram  18
	    		String result = this.methodOne(param1, param2);
	    		return "result:"+result+"\n";
	    	} catch (accessor_one.SomeException112 ex) {
	    		return "SomeException112:"+ex.getMessage()+"\n"; 
	    	}
    	} else {
    		writeLog("Invoke unknown method name: " + methodName);
    	}
		return null;
	}
	
    private void writeLog(String message) {
   	 SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss ");
   	 String logEntry = sdf.format(new Date())+ " ] " +  message;
   	 System.out.println(logEntry);
   }
	
	
	
}
