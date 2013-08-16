import java.awt.AWTException;
import java.io.*;

public class server {

	public server() {
		// TODO Auto-generated constructor stub
	}

	/**
	 * @param args
	 * @throws IOException 
	 * @throws AWTException 
	 */
	public static void main(String[] args) throws IOException, AWTException {
		// TODO Auto-generated method stub
		new udpSocketThread().start();
		
	}

}
