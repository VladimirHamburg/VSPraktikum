package station;

public class Ticker implements Runnable {
	private boolean work_flag = true;
	private TimeManager timeMan;
	private DataExchange dataEx;
	private Long nextFrame;
	private SlotManager slotMan;
	private int prevSlot = 1;
	private int nextSlot = 0;
	
	public Ticker(TimeManager timeMan,SlotManager slotMan,DataExchange dataEx) {
		this.timeMan = timeMan;
		this.dataEx = dataEx;
		this.slotMan = slotMan;
		nextFrame = timeMan.getDelayNextFrame();
	}
	
	@Override	
	public void run() {
		nextSlot = timeMan.getSlotNum(timeMan.getTimestamp())-1;
		while(work_flag){
			try {
				Thread.sleep(timeMan.getDelayNextSlot());
				nextSlot++;
				if(nextSlot == 25){
					nextSlot = 0;
					Thread.sleep(1);
					slotMan.nextFrame(timeMan.getFrameNum());
					timeMan.nextFrame();
					dataEx.proceed(timeMan.getFrameNum());
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
