package station;

public class Ticker implements Runnable {
	private boolean work_flag;
	private DataExchange dataEx;
	@Override
	public void run() {
		while(work_flag){
		}
		
	}
	
	public void stop(){
		work_flag = false;
	}
	
}
