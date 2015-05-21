package mware_lib;

public abstract class NameService {
	
	// Meldet ein Objekt (servant) beim Namensdienst an.
	// Eine eventuell schon vorhandene Objektreferenz gleichen Namens
	// soll überschrieben werden.
	public abstract void rebind(Object servant, String name);
	
	// Liefert eine generische Objektreferenz zu einem Namen. (vgl. unten)
	public abstract Object resolve(String name);

}
