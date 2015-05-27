package accessor_two;

import java.text.SimpleDateFormat;
import java.util.Date;

import mware_lib.Invokeable;

public abstract class ClassOneImplBase implements Invokeable {
	public abstract double methodOne(String param1, double param2) throws SomeException112;
	public abstract double methodTwo (String param1, double param2) throws SomeException112, SomeException304;
	public static ClassOneImplBase narrowCast(Object rawObjectRef) {
		return new ClassOneImpl((String[])rawObjectRef);
	}
	
	public String Invoke(String[] splitData) {
    	String methodName = splitData[1];
    	String param1 = splitData[2];
    	double param2 = Double.parseDouble(splitData[3]);
    	
    	if (methodName.equals("methodOne")) {
        	try {
        		Double result = this.methodOne(param1, param2);
        		return "result:"+result.toString()+"\n";
        	} catch (accessor_two.SomeException112 ex) {
        		return "SomeException112:"+ex.getMessage()+"\n";
        	}
    	} else if (methodName.equals("methodTwo")) {
        	try {
        		Double result = this.methodTwo(param1, param2);
        		return "result:"+result.toString()+"\n";
        	} catch (accessor_two.SomeException112 ex) {
        		return "SomeException112:"+ex.getMessage()+"\n";
        	} catch (accessor_two.SomeException304 ex) {
        		return "SomeException304:"+ex.getMessage()+"\n";
        	}
    	} else {
    		writeLog("unknown method name: " + methodName);
    		return "";
    	}
	}
	
	private void writeLog(String message) {
	   	 SimpleDateFormat sdf = new SimpleDateFormat("[yy-MM-dd hh:mm:ss ");
	   	 String logEntry = sdf.format(new Date())+ " ] " +  message;
	   	 System.out.println(logEntry);
	   }
}
