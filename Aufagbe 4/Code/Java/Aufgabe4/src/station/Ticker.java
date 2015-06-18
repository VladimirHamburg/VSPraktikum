package station;

public class Ticker implements Runnable {
	private boolean work_flag = true;
	private TimeManager timeMan;
	private DataExchange dataEx;
	private Long nextFrame;
	private SlotManager slotMan;
	private int prevSlot = 1;
	private Long nextSlot = 0L;
	
	public Ticker(TimeManager timeMan,SlotManager slotMan,DataExchange dataEx) {
		this.timeMan = timeMan;
		this.dataEx = dataEx;
		this.slotMan = slotMan;
		nextFrame = timeMan.getDelayNextFrame();
	}
	
	@Override	
	public void run() {
		nextSlot = timeMan.getTimestamp()/1000L+1L;
		while(work_flag){
			try {
				Thread.sleep(timeMan.getDelayNextSlot());
				//System.out.println(timeMan.getTimestamp()/1000L + " next->" + nextSlot);
				if(timeMan.getTimestamp()/1000L == nextSlot){
					nextSlot = timeMan.getTimestamp()/1000L+1L;
					//Thread.sleep(1);
					dataEx.proceed(timeMan.getFrameNum());
					slotMan.nextFrame(timeMan.getFrameNum());
					timeMan.nextFrame();
				}else{
					dataEx.proceed(timeMan.getFrameNum());
				}
				if(timeMan.getDelayNextSlot() < 38) Thread.sleep(5);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			
		}
		
	}
	
	public void shutdown(){
		work_flag = false;
	}
	
}
