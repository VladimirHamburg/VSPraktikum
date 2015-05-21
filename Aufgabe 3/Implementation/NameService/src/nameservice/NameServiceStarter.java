package nameservice;

import java.io.*;
import java.net.*;

public class NameServiceStarter {
	
	private static final int PORT_PARAM_ARRAY_POS = 0;
	private static final int MAX_CONNECTIONS_PARAM_ARRAY_POS = 1;
	private static final int MAX_CONNECTIONS_DEFAULT = 500;
	private static final int MAX_PORT_NUMBER = 65536;
	private static final int MIN_PORT_NUMBER = 1;
	public static String usage = "Usage: nameservice <port> [maxConnections=100]";
	
	public static void main(String [] args)
	{
		int port;
		int maxConnections;
		
		if (!CheckPortIsValid(args)) {
			return;
		}
		
		port = Integer.parseInt(args[PORT_PARAM_ARRAY_POS]);
		
		if (CheckMaxConnectionsIsPresent(args)) {
			if(CheckMaxConnectionsIsValid(args)) {
				maxConnections = Integer.parseInt(args[MAX_CONNECTIONS_PARAM_ARRAY_POS]);
			} else {
				return;
			}
		} else {
			maxConnections = MAX_CONNECTIONS_DEFAULT;
		}
		
		
		
		System.out.println("Starting namesevice on port " + port + " allowing "+maxConnections+" concurrent connections");
		(new NameServiceServer(port, maxConnections)).start();
	}
	
	
	/**
	 * Checks if the port parameter is present, correct and available
	 * @return false if the parameter is not present, incorrect or not available
	 */
	private static boolean CheckPortIsValid(String [] args)
	{
		// Check for correct parameters
		if (args.length < PORT_PARAM_ARRAY_POS+1) {
			System.out.println(usage);
			return false;
		}
		
		// Check if port is numeric
		try {
			Integer.parseInt(args[PORT_PARAM_ARRAY_POS]);
		} catch (NumberFormatException  e) {
			System.out.println(usage);
			return false;
		}
		
		int port = Integer.parseInt(args[PORT_PARAM_ARRAY_POS]);
		
		// Check port boundaries
		if (port > MAX_PORT_NUMBER || port < MIN_PORT_NUMBER)
		{
			System.out.println("Port number must be between "+MIN_PORT_NUMBER+" and "+MAX_PORT_NUMBER+"!");
			return false;
		}
		
		// Check if port is already assigned
		if(!available(port))
		{
			System.out.println("Port number "+port+" is already in use!");
			return false;
		}
		
		return true;
	}
	
	/**
	 * Checks if the maxConnections paramter is present
	 * @return true if its present
	 */
	private static boolean CheckMaxConnectionsIsPresent(String [] args)
	{
		return args.length >= 3;
	}
	
	/**
	 * Checks if the maxConnections parameter is  correct and available
	 * @return false if the parameter is not present, incorrect or not available
	 */
	private static boolean CheckMaxConnectionsIsValid(String [] args)
	{
		// Check for correct parameters
		if (args.length < MAX_CONNECTIONS_PARAM_ARRAY_POS+1) {
			System.out.println(usage);
			return false;
		}
		
		// Check if max connections is numeric
		try {
			Integer.parseInt(args[MAX_CONNECTIONS_PARAM_ARRAY_POS]);
		} catch (NumberFormatException  e) {
			System.out.println(usage);
			return false;
		}
		
		int maxConnections = Integer.parseInt(args[MAX_CONNECTIONS_PARAM_ARRAY_POS]);
		
		// Check port boundaries
		if (maxConnections < 1)
		{
			System.out.println("MaxConnections must be a number equal or larger than 1");
			return false;
		}
		
		return true;
	}
		
	/**
	 * Checks to see if a specific port is available.
	 * @param port the port to check for availability
	 */
	private static boolean available(int port) {
	    if (port < MIN_PORT_NUMBER || port > MAX_PORT_NUMBER) {
	        throw new IllegalArgumentException("Invalid start port: " + port);
	    }

	    ServerSocket ss = null;
	    DatagramSocket ds = null;
	    try {
	        ss = new ServerSocket(port);
	        ss.setReuseAddress(true);
	        ds = new DatagramSocket(port);
	        ds.setReuseAddress(true);
	        return true;
	    } catch (IOException e) {
	    } finally {
	        if (ds != null) {
	            ds.close();
	        }

	        if (ss != null) {
	            try {
	                ss.close();
	            } catch (IOException e) {
	                /* should not be thrown */
	            }
	        }
	    }

	    return false;
	}
	
}
