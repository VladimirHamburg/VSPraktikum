package logik;
import accessor_one.ClassOneImplBase;
import accessor_one.SomeException112;


public class A1SampleClassOne extends ClassOneImplBase {

	@Override
	public String methodOne(String param1, int param2) throws SomeException112 {
		if (param2 == 1337) {
			throw new SomeException112("Param2 was to leet!");
		} else {
			return param1 +  ((Integer)(param2+1)).toString();
		}
	}
}
