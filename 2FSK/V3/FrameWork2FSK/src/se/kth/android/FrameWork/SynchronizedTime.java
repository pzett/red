/* Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
* This software is provided  ’as is’. It is free to use for non-commercial purposes.
* For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
* for a license. For non-commercial use, we appreciate citations of our work,
* please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
* for how information on how to cite. */ 

package se.kth.android.FrameWork;

import java.io.BufferedOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.net.SocketException;

import org.apache.commons.net.ntp.NTPUDPClient;
import org.apache.commons.net.ntp.TimeInfo;
import org.apache.commons.net.ntp.TimeStamp;

//import se.kth.android.StudentCode.StudentCode;

public class SynchronizedTime {
	static final int NONTPO = 10000;
	int numO = 0;

	
    public long startMillisLocal;
    public long startNanosLocal;
    long startNanoTimeLocal = 0;
    public long startNtpTimeNetwork = 0;
  	private boolean active = false;
	
	String ntpServer  = null;
	NTPUDPClient client;
	

	Thread st = null;
    void Init(String ntpServer)
    {
        startMillisLocal = System.currentTimeMillis();
        startNanosLocal = System.nanoTime();
    	this.ntpServer = ntpServer;
    	startNanoTimeLocal = TimeStamp.getCurrentTime(startMillisLocal, startNanosLocal).ntpValue();
    	
        client = new NTPUDPClient(startMillisLocal,startNanosLocal);
        

        client.setDefaultTimeout(10000);
    }
    public long startTime = 0;
	private BufferedOutputStream logFile;
    
    void Start()
    {
    	active = true;
		
        st = new Thread(new Runnable() { 
			synchronized public void run() 
        	{ 
        		while(true)
        		{
        			try {
        				if(active)
        					Sync();
						wait(1000);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
        		}
        	}
        	});
     st.start(); 
     
		try {
			logFile = new BufferedOutputStream(new FileOutputStream("/sdcard/sync.csv"), 65536*16);
		
			String s = "C;"+startMillisLocal+";"+startNanosLocal+"\n";
			logFile.write(s.getBytes());
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }
    
    void Stop()
    {
    	active = false;
    	st.stop();
    	if(logFile != null)
		       try {
					logFile.flush();
					logFile.close();
					logFile = null;
				} catch (IOException e) {
					e.printStackTrace();
				}
    }
    
	long shortestDelay = Long.MAX_VALUE;
	public TimeInfo info;
	class NTPOffsets {
		public NTPOffsets(long delayValue, long offsetValue, long returnTime) {
			delay = delayValue;
			offset = offsetValue;
			returnT = returnTime;
		}
		long delay;
		long offset;
		long returnT;
	}
	NTPOffsets ntpoffsets[] = new NTPOffsets[NONTPO];
	public class Parameters {
		public long start;
		public long drift;
	}
	
	public static void fit(NTPOffsets ntpoffsets[], Parameters p)
	{
		double sx=0.0,sy=0.0,sxx=0.0,sxy=0.0;//, del;

		//s = x.length;
		for (int i=0; i < NONTPO; i++){
			if(ntpoffsets[i] != null)
			{
				  sx  += ntpoffsets[i].returnT;
				  sy  += ntpoffsets[i].offset;
				  sxx += ntpoffsets[i].returnT*ntpoffsets[i].returnT;
				  sxy += ntpoffsets[i].returnT*ntpoffsets[i].offset;
			}
		}
		
		//del = - sx*sx;
		
		// Intercept
		double s1 = sxy/sx;
		double s2 = - sxx*sy/(sx*sx);
		double start = s1 + s2;
		p.start =  (long)start;
		// Slope
		double d1 = sy/sx;
		double drift = d1;
		p.drift =  (long)drift;
		
		
		// Errors  (sd**2) on the:
		// intercept
		// = sxx/del;
		// and slope
		// = s/del;

	} // fit

	public Parameters p = null;
	long offsetValue = 0;
    long delayValue = 0;
    long returnTime = 0;
    
	void Sync() {
            try {
                InetAddress hostAddr = InetAddress.getByName(ntpServer);

               try {
        			client.open();
        		} catch (SocketException e1) {
        			e1.printStackTrace();
        		}
                
                info = client.getTime(hostAddr);
                info.computeDetails();

                
    			String s = "S;"+info.getMessage().getOriginateTimeStamp().ntpValue()+";"+
                		info.getMessage().getReceiveTimeStamp().ntpValue()+";"+
                		info.getMessage().getTransmitTimeStamp().ntpValue()+";"+
                		info.getReturnTime()+"\n";
    			logFile.write(s.getBytes());
              
                                
                
                
                // Values in nanoseconds
                if(returnTime == 0)
                {
                	offsetValue =info.getOffset();
                }
                //
                //offsetValue =info.getOffset();
                delayValue = info.getDelay();//TimeStamp.fromNtpToNanos(info.getDelay());
                returnTime = info.getReturnTime();//TimeStamp.fromNtpToNanos(info.getReturnTime())-startNanoTimeLocal;
  
                if(offsetValue == 0)
                	return;

                if(delayValue<shortestDelay*3)
                {
                	//offsetValue = (offsetValue*9 + info.getOffset())/10;//TimeStamp.fromNtpToNanos(info.getOffset());
                	offsetValue = info.getOffset();//(offsetValue*9 + info.getOffset())/10;//TimeStamp.fromNtpToNanos(info.getOffset());
	                for(int i=1;i<NONTPO;i++)
	                {
	                	ntpoffsets[i-1] = ntpoffsets[i];
	                }
	            	ntpoffsets[NONTPO-1] = new NTPOffsets(delayValue,offsetValue,returnTime);
                }
                

                p = new Parameters();
                
                //fit(ntpoffsets,p);
      
 
            } catch (IOException ioe) {
                ioe.printStackTrace();
            }
     }
	
	long nowNetworkTimeNanos()
	{
		// Get local time in nanoseconds
		long now_ntp_fractional = TimeStamp.getCurrentTime(startMillisLocal, startNanosLocal).ntpValue();
		
		if(p!=null) // Correct the time from network 
		{
			now_ntp_fractional = (now_ntp_fractional-startNanoTimeLocal)*p.drift+p.start;			
		}

		long now_seconds = now_ntp_fractional/0x100000000L;
		long now_fraction = now_ntp_fractional&0xFFFFFFFF;
		long now_nanos = now_fraction*1000000000L/0x100000000L;
		long now_time_nanos = now_seconds*1000000000L+now_nanos;
		
		return now_time_nanos;
	}

}
