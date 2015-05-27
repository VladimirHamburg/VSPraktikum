package sampleserver;
import accessor_two.*;

public class A2SampleClassOne extends ClassOneImplBase {

	@Override
	public double methodOne(String param1, double param2)
			throws SomeException112 {
		if (param2 < 0) {
			throw new SomeException112("Param2 cant be negative!");
		} else {
			return -param2;
		}
	}

	@Override
	public double methodTwo(String param1, double param2)
			throws SomeException112, SomeException304 {
		if (param2 > 0) {
			throw new SomeException304("Param2 cant be positive!");
		} else if (param2 < 0) {
			throw new SomeException112("Param2 cant be negative!");
		} else {
			return param2;
		}
	}
}
