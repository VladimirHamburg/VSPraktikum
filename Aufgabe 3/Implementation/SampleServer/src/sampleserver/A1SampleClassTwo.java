package sampleserver;
import java.util.*;

import accessor_one.*;


public class A1SampleClassTwo extends ClassTwoImplBase {

	@Override
	public int methodOne(double param1) throws SomeException110 {
		if (param1 > 1336) {
			throw new SomeException110("You cant write numbers above 1336!");
		} else {
			return (int)(param1);
		}
	}

	@Override
	public double methodTwo() throws SomeException112 {
		if (new Random().nextBoolean()) {
			throw new SomeException112("50 / 50 chance. You failed!");
		}
		return 1337.3;
	}
	
}
