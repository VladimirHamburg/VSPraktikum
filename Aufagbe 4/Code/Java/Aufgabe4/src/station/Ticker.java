package station;

public class Ticker implements Runnable {
	private boolean work_flag = true;
	private TimeManager timeMan;
	private DataExchange dataEx;
	private Long nextFrame;
	private SlotManager slotMan;

	
	public Ticker(TimeManager timeMan,SlotManager slotMan,DataExchange dataEx) {
		this.timeMan = timeMan;
		this.dataEx = dataEx;
		this.slotMan = slotMan;
		nextFrame = timeMan.getDelayNextFrame()-10L;
	}
	
	@Override	
	public void run() {
		while(work_flag){
			try {
				Thread.sleep(timeMan.getDelayNextSlot());
				if(nextFrame < timeMan.getDelayNextFrame()){
					nextFrame = timeMan.getDelayNextFrame()-10L;
					slotMan.nextFrame(timeMan.getFrameNum());
					timeMan.nextFrame();
					dataEx.proceed(timeMan.getFrameNum()-1);
				}else{
					dataEx.proceed(timeMan.getFrameNum());
				}
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
