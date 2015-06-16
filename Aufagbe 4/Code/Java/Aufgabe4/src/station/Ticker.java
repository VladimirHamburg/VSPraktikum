package station;

public class Ticker implements Runnable {
	private boolean work_flag = true;
	private TimeManager timeMan;
	private DataExchange dataEx;

	
	public Ticker(TimeManager timeMan,DataExchange dataEx) {
		this.timeMan = timeMan;
		this.dataEx = dataEx;
	}
	
	@Override	
	public void run() {
		while(work_flag){
			try {
				Thread.sleep(timeMan.getDelayNextSlot());
				dataEx.proceed(timeMan.getFrameNum());
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
//			if(timeMan.getDelayNextSlot() == 20L){
//				System.out.println("MIDDLE!!! " + timeMan.getTimestamp());
//				try {
//					Thread.sleep(2L);
//				} catch (InterruptedException e) {
//					// TODO Auto-generated catch block
//					e.printStackTrace();
//				}
//			}
			
		}
		
	}
	
	public void shutdown(){
		work_flag = false;
	}
	
}
