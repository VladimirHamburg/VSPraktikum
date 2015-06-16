package station;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;

public class Starter {


	public static void main(String[] args) {
		PacketBuffer p = new PacketBuffer('A');
		SlotManager sM = new SlotManager();
		TimeManager tM = new TimeManager(0L);
		DataExchange dE = new DataExchange(sM, tM);
		Ticker t = new Ticker(tM, sM, dE);
		Receiver r = new Receiver("225.10.1.2", "lo", 15009, dE);
		try {
			Sender s = new Sender(p, sM, tM, "225.10.1.2", 15009, "lo");
			Thread sT = new Thread(s);
			sT.start();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		Thread pt = new Thread(p);
		pt.start();
//		Thread tMt = new Thread(tM);
//		tMt.start();
		Thread tt = new Thread(t);
		tt.start();
		Thread rT = new Thread(r);
		rT.start();

	}

}
