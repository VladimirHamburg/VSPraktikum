package mware_lib;

public abstract class NameService {
	
	/**
	 * Registers an object by the name service
	 * @param servant The object to register
	 * @param name The name the object is identified by
	 */
	public abstract void rebind(Object servant, String name);
	
	/**
	 * Resolves an object by the name service
	 * @param name The name the object is identified by
	 * @return The raw object that belong to the name
	 */
	public abstract Object resolve(String name);

}
