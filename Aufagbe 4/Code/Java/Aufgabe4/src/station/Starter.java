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
		String netInterface = args[0];
		String netAddress = args[1];
		int netPort = Integer.parseInt(args[2]);
		char stationType = args[3].toUpperCase().charAt(0);
		long startDerivation = 0L;
		if (args.length == 5) {
			startDerivation = Long.parseLong(args[4]);
		}
		
		PacketBuffer p = new PacketBuffer(stationType);
		SlotManager sM = new SlotManager();
		TimeManager tM = new TimeManager(startDerivation, stationType);
		DataExchange dE = new DataExchange(sM, tM);
		Ticker t = new Ticker(tM, sM, dE);
		Receiver r = new Receiver(netAddress, netInterface, netPort, dE);
		try {
			Sender s = new Sender(p, sM, tM, netAddress, netPort, netInterface);
			Thread sT = new Thread(s);
			sT.start();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		Thread pt = new Thread(p);
		pt.start();
		Thread tt = new Thread(t);
		tt.start();
		Thread rT = new Thread(r);
		rT.start();

	}

}
