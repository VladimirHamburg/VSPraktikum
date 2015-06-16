package station;

public class Ticker implements Runnable {
	private boolean work_flag;
	private TimeManager timeMan;
	private DataExchange dataEx;
	@Override
	public void run() {
		while(work_flag){
			try {
				Thread.sleep(timeMan.getDelayNextSlot());
				dataEx.proceed(timeMan.getFrameNum());
			} catch (InterruptedException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
	}
	
	public void stop(){
		work_flag = false;
	}
	
}
