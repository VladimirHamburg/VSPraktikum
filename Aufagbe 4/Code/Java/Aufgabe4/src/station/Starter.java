package station;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.Calendar;

public class Starter {


	public static void main(String[] args) {
	System.out.println("Nigga!");
		PacketBuffer p = new PacketBuffer('A');
		p.run();
//		Thread t = new Thread(p);
//		t.run();
		// TODO Auto-generated method stub
		//Receiver newR = new Receiver("225.10.1.2", "lo", 15009,null,null);
		//newR.run();
		Calendar cald = Calendar.getInstance();
		// TODO Auto-generated method stub
		//Receiver newR = new Receiver("225.10.1.2", "lo", 15009,null,null);
		//newR.run();
		TimeManager tm = new TimeManager(10L);
		Thread tmt = new Thread(tm);
		tmt.start();
		while(true){
			System.out.println(tm.getFrameNum());
		}
	}

}
