package accessor_one;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;
import java.text.SimpleDateFormat;
import java.util.Date;

import mware_lib.Invokeable;

public abstract class ClassTwoImplBase implements Invokeable {
	public abstract int methodOne(double param1) throws SomeException110;
	public abstract double methodTwo() throws SomeException112;
	public static ClassTwoImplBase narrowCast(Object rawObjectRef) {
		return new ClassTwoImpl((String[])rawObjectRef);
	}
	
	public String Invoke(String[] splitData) {
    	String methodName = splitData[1];
	  	
    	if (methodName.equals("methodOne")) {
        	try {
        		double param1 = Double.parseDouble(splitData[2]);
        		Integer result = this.methodOne(param1);
        		return "result:"+result.toString()+"\n";
        	} catch (accessor_one.SomeException110 ex) {
        		return "SomeException110:"+ex.getMessage()+"\n";
        	}
    	} else if (methodName.equals("methodTwo")) {
        	try {
        		Double result = this.methodTwo();
        		return "result:"+result.toString()+"\n";
        	} catch (accessor_one.SomeException112 ex) {
        		return "SomeException112:"+ex.getMessage()+"\n";
        	}
    	} else {
    		return "";
    	}
	}
	

}
