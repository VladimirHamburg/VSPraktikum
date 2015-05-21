package accessor_one;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;

public abstract class ClassTwoImplBase {
	public abstract int methodOne(double param1) throws SomeException110;
	public abstract double methodTwo() throws SomeException112;
	public static ClassTwoImplBase narrowCast(Object rawObjectRef) {
		return new ClassTwoImpl((String[])rawObjectRef);
	}
}
