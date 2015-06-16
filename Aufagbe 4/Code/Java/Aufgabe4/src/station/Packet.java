package station;

import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.security.InvalidParameterException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.concurrent.Semaphore;

public class Packet {

	public static final int CLASS_START = 0;
	public static final int CLASS_SIZE = 1;
	public static final int PAYLOAD_START = 1;
	public static final int PAYLOAD_SIZE = 24;
	public static final int SLOTNUM_START = 25;
	public static final int SLOTNUM_SIZE = 1;
	public static final int TIMESTAMP_START = 26;
	public static final int TIMESTAMP_SIZE = 8;
	
	private byte[] raw;
	
	public Packet() {
		this.raw = new byte[CLASS_SIZE + PAYLOAD_SIZE + SLOTNUM_SIZE + TIMESTAMP_SIZE]; 
	}
	
	public Packet(char stationType, byte[] payload) {
		this.raw = new byte[CLASS_SIZE + PAYLOAD_SIZE + SLOTNUM_SIZE + TIMESTAMP_SIZE];
		setStation(stationType);
		setPayload(payload);
	}
	
	public Packet(byte[] raw) {
		this.raw = raw.clone();
	}
	
	private byte[] longToBytes(long x) {
	    ByteBuffer buffer = ByteBuffer.allocate(Long.BYTES);
	    buffer.putLong(x);
	    return buffer.array();
	}

	private long bytesToLong(byte[] bytes) {
	    ByteBuffer buffer = ByteBuffer.allocate(Long.BYTES);
	    buffer.put(bytes);
	    buffer.flip();//need flip 
	    return buffer.getLong();
	}
	
	@Override
	public String toString()
	{
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss.SSS");	
		try {
			return "Class:" + getClass() + 
					" Payload:" + new String(getPayload(), "UTF-8") + 
					" Plen:" + new String(getPayload(), "UTF-8").length() +
					" Slot:" + getSlotNum() + 
					" Time:" + sdf.format(new Date(getTimestamp()));
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return "";
	}	

	// ** GETTER / SETTER ** //
	public char getStation()
	{
		return (char)raw[CLASS_START];
	}
	
	public byte[] getPayload()
	{
		return Arrays.copyOfRange(raw, PAYLOAD_START, PAYLOAD_START + PAYLOAD_SIZE);		
	}
	
	public byte getSlotNum()
	{
		return raw[SLOTNUM_START];	
	}
	
	public long getTimestamp()
	{
		return bytesToLong(Arrays.copyOfRange(raw, TIMESTAMP_START, TIMESTAMP_START + TIMESTAMP_SIZE));	
	}
	
	public byte[] getRaw() {
		return raw.clone();
	}

	public void setStation(char stationStation) {
		this.raw[CLASS_START] = (byte)stationStation;
	}
	
	public void setPayload(byte[] data)
	{
		if (data.length != PAYLOAD_SIZE) {
			throw new InvalidParameterException("Parameter does not have the size of " + PAYLOAD_SIZE);
		}
		
		for (int i = 0; i < PAYLOAD_SIZE; i++) {
			raw[PAYLOAD_START + i] = data[i];
		}
	}
	
	public void setSlotNum(byte slotNum) {
		this.raw[SLOTNUM_START] = slotNum;
	}
	
	public void setTimestamp(long millis) {
		byte[] t = longToBytes(millis);
		for (int i = 0; i < TIMESTAMP_SIZE; i++) {
			raw[TIMESTAMP_START + i] = t[i];
		}
	}
}
