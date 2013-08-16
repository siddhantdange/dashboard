import java.io.*;
import java.net.*;
import java.util.*;
import java.awt.*;


public class udpSocketThread extends Thread{
	
	protected DatagramSocket socket = null;
	protected BufferedReader in = null;
	protected Robot robot=null;
	
	
	public udpSocketThread() throws IOException, AWTException {
		this("socketThread");
	}
	
	public udpSocketThread(String stuff) throws IOException, AWTException {
		super(stuff);
		socket=new DatagramSocket(1234);
		robot=new Robot();
	}
	
	public void run(){
		while(true){
			try {
				sleep(1);
				//sleep(10);
			} catch (InterruptedException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			try{
				byte[] buf = new byte[256];
   
				// receive request
				DatagramPacket packet = new DatagramPacket(buf, buf.length);
				socket.receive(packet);
				String someString=new String(packet.getData());
				String[]stringArray=someString.split(",");
				if(stringArray.length>=3){
					int x=(int) Float.parseFloat(stringArray[0]);
					int y=(int) Float.parseFloat(stringArray[1]);
					System.out.printf("%d,%d",x,y);
					robot.mouseMove(x,y);
				}
				
				for (int j = 0; j < stringArray.length; j++) {
					String i = stringArray[j];
					System.out.println(i);
				}
			}
			catch (IOException e){
				e.printStackTrace();
			}

		}
	}
	

}
