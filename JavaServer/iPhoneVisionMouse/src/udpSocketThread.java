import java.io.*;
import java.net.*;
import java.util.*;
import java.awt.*;


public class udpSocketThread extends Thread{
	
	protected /*DatagramSocket*/ServerSocket socket = null;
	protected BufferedReader in = null;
	protected Robot robot=null;
	
	
	public udpSocketThread() throws IOException, AWTException {
		this("socketThread");
	}
	
	public udpSocketThread(String stuff) throws IOException, AWTException {
		super(stuff);
		socket=new ServerSocket(1235);//DatagramSocket(1234);
		robot=new Robot();
	}
	
	public void run(){
		int n = 0;
		System.out.printf("going\n");
//		ServerSocket socket = null;
//		try {
//			socket = new ServerSocket(1234);
//		}
//		catch (IOException e) {
//			System.out.printf("couldn't create socket");
//		}
		while(true){
			try {
				sleep(1);
				//sleep(10);
			} catch (InterruptedException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			try{
				//byte[] buf = new byte[256];
				//System.out.printf("hi");
				// receive request
				//DatagramPacket packet = new DatagramPacket(buf, buf.length);
				//socket.receive(packet);
				Socket sock = socket.accept();
				//System.out.printf("hey0");
	            BufferedReader inFromClient = new BufferedReader(new InputStreamReader(sock.getInputStream()));
	            //System.out.printf("hey1");
				String someString=inFromClient.readLine();//new String(packet.getData());
				System.out.println(someString);
				//System.out.printf("hey2");
				String[]stringArray=someString.split(",");
				if(stringArray.length>=3){
					int x=(int) Float.parseFloat(stringArray[0]);
					int y=(int) Float.parseFloat(stringArray[1]);
					System.out.printf("%d,%d\n",x,y);
					//robot.mouseMove(x,y);
					n++;
					if (n > 10) {
						//System.out.printf("I'm out\n");
						//break;
					}
				}
				
				//System.out.printf("heyo");
				
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
