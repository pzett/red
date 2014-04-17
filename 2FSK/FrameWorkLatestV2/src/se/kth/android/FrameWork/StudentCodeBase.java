/* Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
* This software is provided  ’as is’. It is free to use for non-commercial purposes.
* For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
* for a license. For non-commercial use, we appreciate citations of our work,
* please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
* for how information on how to cite. */ 

package se.kth.android.FrameWork;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.net.HttpURLConnection;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.MalformedURLException;
import java.net.NetworkInterface;
import java.net.ServerSocket;
import java.net.Socket;
//import java.net.SocketAddress;
import java.net.SocketException;
import java.net.URL;
import java.nio.ByteBuffer;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.BufferedWriter;
import java.io.FileWriter;

import se.kth.android.StudentCode.StudentCode;
import se.kth.android.StudentCode.StudentMessage;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.media.SoundPool;
import android.media.AudioTrack.OnPlaybackPositionUpdateListener;
import android.net.wifi.ScanResult;
import android.os.Environment;
//import android.widget.Toast;

public class StudentCodeBase implements OnPlaybackPositionUpdateListener  {

	public FrameWork frameWork;
	public String ntpServer = null;//"se.pool.ntp.org";
	public String projectName = "null";
	 
	public int useSensors = 0;
	public int sampleRate = 8000;
	
	public boolean useCameraGUI=true;
	public boolean useAutoFocus=false;
	
	public boolean userInputString=false;
	public String userInputStringMenuItem="Input String";
	public String userInputStringTitle="Title";
	public String userInputStringMessage="Message";

	
	public boolean logSound=true;
	public boolean useConcurrentLocks = false;
	public boolean useMessaging = false;
	public String messageServer = null;
	public static final int WEB_MESSAGE_SERVER = 1; 
	public static final int LINUX_MESSAGE_SERVER = 2;
	public static final int PHONE_SERVER = 3;
	public int messageServerType = WEB_MESSAGE_SERVER;
	
	public String[] messageGroups = null;
	public int myGroupID = -1;
	
	public boolean loggingOn = false;
	public long processInterval = 0;
	public String introText = null;
	
	public class ProjectMember 
	{
		String ip = null;
		int groupId;
	}
	
	public ArrayList<ProjectMember> ips = new ArrayList<ProjectMember>();
	
	
	public boolean streamingSink = true;

	public DecimalFormat format4_4 = new DecimalFormat("0000.0000");
	public DecimalFormat format4_2 = new DecimalFormat("###0.00");
	public DecimalFormat format4_0 = new DecimalFormat("####");
	
	public String textOutput = null;
	
	public static final int ACCELEROMETER = 1; 
	public static final int MAGNETIC_FIELD = 2; 
//	public static final int COMPASS = 4; 
	public static final int PROXIMITY = 8; 
	public static final int GPS = 16; 
	public static final int LIGHT = 32; 
	public static final int SOUND_IN = 64; 
	public static final int SOUND_OUT = 128; 
	public static final int TIME_SYNC = 256;
	public static final int WIFI_SCAN = 512;
	public static final int CAMERA = 1024;
	public static final int GYROSCOPE = 2048;
	public static final int CAMERA_RGB = 4096;

	
	public Paint green = new Paint();
	public Paint red = new Paint();
	public Paint yellow = new Paint();
	public Paint orange = new Paint();
	public Paint blue = new Paint();

	public StudentCodeBase() 
	{
        green.setColor(Color.GREEN);
        green.setAntiAlias(true);
        green.setStrokeWidth(3);
        red.setColor(Color.RED);
        red.setAntiAlias(true);
        red.setStrokeWidth(3);
        yellow.setColor(Color.YELLOW);
        yellow.setAntiAlias(true);
        yellow.setStrokeWidth(3);
        orange.setColor(Color.rgb(255, 140, 0));
        orange.setAntiAlias(true);
        orange.setStrokeWidth(3);
        blue.setColor(Color.BLUE);
        blue.setAntiAlias(true);
        blue.setStrokeWidth(3);	
                
    }

	void checkServerLinux()
	{
		
		InetSocketAddress serverAddress = new InetSocketAddress(messageServer,2323);
		Socket client = new Socket();
		try
		{	 		
			client.connect(serverAddress);
			DataOutputStream dos = new DataOutputStream(client.getOutputStream());
			DataInputStream dis = new DataInputStream(client.getInputStream());
			
			
			dos.writeBytes(projectName);
			String clientIP = dis.readLine();			
			client.close();
			
					
			
			if(!clientIP.equals("0.0.0.0")&&isIP(clientIP)&&!clientIP.equals(getLocalIpAddress()))
			{
				InetSocketAddress clientAddr2 = new InetSocketAddress(clientIP,4711);
				Socket client2 = new Socket();
				client2.setSoTimeout(500); // We must be on the same network to get fast response
				client2.connect(clientAddr2);
				DataOutputStream dos2 = new DataOutputStream(client2.getOutputStream());
				DataInputStream dis2 = new DataInputStream(client2.getInputStream());
		
				dos2.writeUTF("M:STARTUP_SYNC,"+frameWork.synchronizedTime.startTime+":"+getIPGroupIdList()+"\n");
				String s = dis2.readUTF();

				mergeIPs(s);
				
				client2.close();
				
				raw_message_out("GROUP_SYNC", -1);
			};
		
		} catch (IOException e) {
		}			 			
	}
	
	
	void checkServerPhone()
	{
		
		
		String clientIP=messageServer;
		
		try {
		if(!clientIP.equals("0.0.0.0")&&isIP(clientIP)&&!clientIP.equals(getLocalIpAddress()))
		{
			InetSocketAddress clientAddr2 = new InetSocketAddress(clientIP,4711);
			Socket client2 = new Socket();
			client2.setSoTimeout(500); // We must be on the same network to get fast response
			client2.connect(clientAddr2);
			DataOutputStream dos2 = new DataOutputStream(client2.getOutputStream());
			DataInputStream dis2 = new DataInputStream(client2.getInputStream());
		
			dos2.writeUTF("M:STARTUP_SYNC,"+frameWork.synchronizedTime.startTime+":"+getIPGroupIdList()+"\n");
			String s = dis2.readUTF();

			mergeIPs(s);
			client2.close();	
			raw_message_out("GROUP_SYNC", -1);
				
		}}  
	   catch (IOException e) {
	   }			

	};
	
		
	void checkServerWeb()
	{
		URL u;
		try {
			u = new URL("http://"+messageServer+"/getmaster.php?pname="+projectName+"&ip="+getLocalIpAddress());
	
			HttpURLConnection con = (HttpURLConnection) u.openConnection();
			con.setReadTimeout(2000);
			con.setConnectTimeout(2000);
			con.setRequestMethod("GET");
			con.setDoInput(true);
			con.connect();
			DataInputStream dis = new DataInputStream(con.getInputStream());
			String clientIP = dis.readLine();

			con.disconnect();
		
			if(isIP(clientIP)&&!clientIP.equals(getLocalIpAddress()))
			{
				InetSocketAddress clientAddr = new InetSocketAddress(clientIP,4711);
				Socket client = new Socket();
				client.setSoTimeout(500); // We must be on the same network to get fast response
				client.connect(clientAddr);
				DataOutputStream dos = new DataOutputStream(client.getOutputStream());
				dis = new DataInputStream(client.getInputStream());
		
				dos.writeUTF("M:STARTUP_SYNC,"+frameWork.synchronizedTime.startTime+":"+getIPGroupIdList()+"\n");
				String s = dis.readUTF();
				mergeIPs(s);
				
				client.close();
				
				raw_message_out("GROUP_SYNC", -1);
			}
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
	}
	
    public void start_up(FrameWork frameWorkArg)
    {
        frameWork = frameWorkArg;
        
        if(useMessaging)
        {

            if(messageGroups != null)
            {
                AlertDialog.Builder builder = new 
AlertDialog.Builder(frameWork);
                builder.setTitle("Select group ID for this phone");
                builder.setItems(messageGroups, new 
DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int item) {
                        myGroupID = item;
                        Thread ipListenerThread = new Thread(new 
Runnable() {
                            synchronized public void run()
                            {
                                listenSocket();
                            }});
                        
                        mergeIPs(getLocalIpAddress()+";"+myGroupID);
                        ipListenerThread.start();


                        if(messageServerType == WEB_MESSAGE_SERVER)
                            checkServerWeb();
                        else if (messageServerType == LINUX_MESSAGE_SERVER)
                            checkServerLinux();
                        else
                        	checkServerPhone();
                    }
                });
                AlertDialog alert = builder.create();
                alert.show();
            }
            else
            {
                Thread ipListenerThread = new Thread(new Runnable() {
                    synchronized public void run()
                    {
                        listenSocket();
                    }});


                mergeIPs(getLocalIpAddress()+";"+myGroupID);
                ipListenerThread.start();

                if(messageServerType == WEB_MESSAGE_SERVER)
                    checkServerWeb();
                else if (messageServerType == LINUX_MESSAGE_SERVER)
                    checkServerLinux();
                else
                	checkServerPhone();
                
            }

        }
        if(streamingSink)
        {
            Thread ipSoundListenerThread = new Thread(new Runnable() {
                synchronized public void run()
                {
                    listenBufferSocket();
                }});

            ipSoundListenerThread.start();
        }
    }

	
	protected void clear_output_text() { textOutput = new String(); }
	protected void add_output_text_line(String line) { textOutput += "\n" + line; }
	protected void set_output_text(String text) { textOutput = text; }
	
	public void gps(long time, double latitude, double longitude, double height, double precision){}

	public void magnetic_field(long time, double x, double y, double z){}
	
	public void light(long time, double l){}

	public void proximity(long time, double p){}

	public void accelerometer(long time, double x, double y, double z){}
	
	public void gyroscope(long time, double x, double y, double z){}
	
	public void sound_in(long time, short[] samples, int length){}
	
	public void write_string_on_logfile(String s)
	{
		frameWork.write_string_on_logfile(s+"\n");
	}
	
	public byte[] read_data_from_file(String filename) {
		return frameWork.read_data_from_file(filename);
	}
	
	public byte[] read_rgb_frame_from_file(int image_number, String filename) {		
		byte[] frame;
		frame=frameWork.read_rgb_frame_from_file(image_number, filename);
		return frame;	
	}
	
	public void stringFromUser(String user_input){};
	
	public void stringFromBrowseForFile(String filename) {};	

	public void save_rgb_frame_on_file(String filename,byte[] frame,int width,int height,boolean append) {
    /* The filename MUST be of the format videoNNNNNNNNNNNN.rec where "N" are digits
	   0-9, in order for our Matlab scripts to work properly. 
	   If the file already exists, then additional frames are added (appended) if
	   append=true. If not, every new frame will erase the old one. */		
	   frameWork.save_rgb_frame_on_file(filename, frame,width,height,append);
	
	}

	
		
	public int read_rgb_frame_width_from_file(int image_number, String filename) {
		
		return frameWork.read_rgb_frame_width_from_file(image_number, filename);
	
	}

	public int read_rgb_frame_height_from_file(int image_number, String filename) {
		
		return frameWork.read_rgb_frame_height_from_file(image_number, filename);
	 
	}

	
	SoundPool sp = null;
	int currentSound = -1;
	int currentStreamId = -1;
	
	// Stop play the sound file started with play_sound_file
	public void stop_sound_file()
	{
		if(sp != null)
		{
			if(currentStreamId != -1)
				sp.stop(currentStreamId);
			currentStreamId = -1;
		}
		
	}

	// Play loaded wav file, loop number of times.
	public void play_sound_file(int loop)
	{
		if(sp != null)
		{
			if(currentSound != -1) {
				currentStreamId = sp.play(currentSound,0.99f, 0.99f, 1, loop, 1.0f);
			};
		}
	} 
	
	// load wav file
	public void load_sound_file(String fileName)
	{
		

		if(sp == null)
			sp = new SoundPool(1, AudioManager.STREAM_MUSIC, 0);
		else
		{
			if(currentSound != -1)
				sp.stop(currentSound);
			sp.release();
			sp = new SoundPool(10, AudioManager.STREAM_MUSIC, 0);			
		}				
		File dir = new File(Environment.getExternalStorageDirectory().getPath());
		String filename_with_path = new String(dir+"/"+fileName);

		
		//currentSound = sp.load("/sdcard/"+fileName, 1);
		currentSound = sp.load(filename_with_path, 1);
		
		Thread thread = new Thread()
		{
		    @Override
		    public void run() {
		        try {
		            //while(true) {
		            sleep(1000);
		            //}
		        } catch (InterruptedException e) {
		            e.printStackTrace();
		        }
		    }
		};
		
		thread.start();
		try {
			thread.join(1000);
	     } catch (InterruptedException e) {
            e.printStackTrace();
        };
       
	};


	AudioTrack player = null;
	public void sound_out(short[] buffer, int length)
	{
		if(player == null)
		{
			int playBufferSize = AudioTrack.getMinBufferSize(sampleRate, AudioFormat.CHANNEL_CONFIGURATION_MONO, AudioFormat.ENCODING_PCM_16BIT);
	    	player = new AudioTrack(AudioManager.STREAM_MUSIC, sampleRate, AudioFormat.CHANNEL_CONFIGURATION_MONO, AudioFormat.ENCODING_PCM_16BIT, playBufferSize, AudioTrack.MODE_STREAM);
	    	player.setStereoVolume(1.0f, 1.0f);
	    	player.setPlaybackPositionUpdateListener(this);
	        player.setNotificationMarkerPosition(128);
	        player.setStereoVolume(1.0f,1.0f);
	        player.play();
		}
        player.write(buffer, 0, length);
	}
	
	public void wifi_ap(long time, List<ScanResult> wifi_list){}
	
	public void message_in(StudentMessage message){}		

	
	String getLocalIpAddress() {
	    try {
	        for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
	            NetworkInterface intf = en.nextElement();
	            for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();) {
	                InetAddress inetAddress = enumIpAddr.nextElement();
	                if ((!inetAddress.isLoopbackAddress()) && (isIP(inetAddress.getHostAddress().toString()))) {
	                    return inetAddress.getHostAddress().toString();
	                }
	            }
	        }
	    } catch (SocketException ex) {

	    }
	    return null;
	}
	
	boolean isIP( String  ipAddress )
	{
	    String[] parts = ipAddress.split( "\\." );

	    
	    if ( parts.length != 4 )
	    {
	        return false;
	    }

	    for ( String s : parts )
	    {
	        int i = Integer.parseInt( s );

	        if ( (i < 0) || (i > 255) )
	        {
	            return false;
	        }
	    }

	    return true;
	}
	
	void mergeIPs(String newIPGroupIDs)
	{
		if (!(newIPGroupIDs==null)) {
			String newIPGroupId[] = newIPGroupIDs.split(",");
			for(String ipGroupId:newIPGroupId)
			{
				String temp[] = ipGroupId.split(";");
				Boolean hasIP = false;
				for(ProjectMember s : ips)
					if(s.ip != null && s.ip.equals(temp[0]))
					hasIP = true;
				if(!hasIP && isIP(temp[0]))
				{
					ProjectMember pm = new ProjectMember();
					pm.ip = temp[0];
					pm.groupId = Integer.valueOf(temp[1]);
					ips.add(pm);
				}
			}
		}
	}
	
	void listenSocket()
	{
		

		try {
			ServerSocket socket = new ServerSocket(4711);
		
			while(true)
			{
				Socket receive = socket.accept();
				DataInputStream dis = new DataInputStream(receive.getInputStream());
				DataOutputStream dos = new DataOutputStream(receive.getOutputStream());
				String packet = dis.readUTF();
				String parts[] = packet.split(":");
				switch(parts[0].charAt(0))
				{
				case 'M':
					if(parts[1].contains("STARTUP_SYNC")) {
						String[] dm = parts[1].split(",");
						frameWork.synchronizedTime.startNtpTimeNetwork = Long.parseLong(dm[1]);
					} else if (parts[1].contains("GROUP_SYNC")) {
						
					} else {						
						StudentMessage msg = StudentMessage.fromString(parts[1]);
						message_in(msg);
					};
					
					/*
					if(!parts[1].contains("STARTUP_SYNC"))
					{
						StudentMessage msg = StudentMessage.fromString(parts[1]);
						message_in(msg);
					}
					else if(!parts[1].contains("GROUP_SYNC"))
					{
						String[] dm = parts[1].split(",");
						frameWork.synchronizedTime.startNtpTimeNetwork = Long.parseLong(dm[1]);
					}
					*/
					
					dos.writeUTF(getIPGroupIdList());
					mergeIPs(parts[2]);
					break;
				}
				receive.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	void listenBufferSocket()
	{
		try {
			ServerSocket socket = new ServerSocket(4712);

			while(true)
			{
				Socket receive = socket.accept();
				DataInputStream dis = new DataInputStream(receive.getInputStream());
				int length = dis.readInt();
				short[] buffer = new short[length];
				for(int i=0;i<length;i++)
					buffer[i] = dis.readShort();
				
				InetSocketAddress remoteAddress = (InetSocketAddress)receive.getRemoteSocketAddress();
				byte[] ip = remoteAddress.getAddress().getAddress();
				streaming_buffer_in(buffer, length, ip[3]);
				receive.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}	
	String getIPGroupIdList()
	{
		String o = "";
		for(ProjectMember pm : ips)
			if(pm != null && pm.ip!= null)
				o += pm.ip + ';' + pm.groupId + ',';
		o+="\n";
		return o;
	}
	
	boolean haveIP(String ip)
	{
		Boolean haveIt = false;
		for(ProjectMember pm : ips)
		{
			if(pm != null && pm.ip != null && pm.ip.equals(ip))
				haveIt = true;
		}
		return haveIt;
	}
	
	public void message_out(StudentMessage message)
	{
		message_out(message,null);
	}
	
	public void message_out(StudentMessage message, int groupId) {
		String msg;
		
		if(message != null)
			msg = message.toString();
		else
			return;
			
		raw_message_out(msg, groupId);
	
	}
	
	public void message_out(StudentMessage message, String groupIdString)
	{

		
		if(useMessaging)
		{
			
			String msg;
			int groupId = -1;
			int i = 0;
			
			if ((!(messageGroups==null)) && (!(groupIdString==null))){
								
				for(String g:messageGroups)
				{
					if(g.equals(groupIdString))
						groupId = i;
					i++;
				}
			};
			
			if(message != null)
				msg = message.toString();
			else
				return;
				
			raw_message_out(msg, groupId);
		}
	}

	private void raw_message_out(String msg, int groupId) {
		for(ProjectMember pm : ips)
		{			
			if(pm != null && pm.ip != null && !pm.ip.equals(getLocalIpAddress()) && ((groupId == -1)||(pm.groupId == groupId)))
			{
				InetSocketAddress clientAddr = new InetSocketAddress(pm.ip,4711);
				Socket client = new Socket();
				try
				{			
					client.connect(clientAddr);
					DataOutputStream dos = new DataOutputStream(client.getOutputStream());
					DataInputStream dis = new DataInputStream(client.getInputStream());
					
					dos.writeUTF("M:"+msg+":"+getIPGroupIdList()+"\n");
					String s = dis.readUTF();
					mergeIPs(s);
					
					client.close();
				} catch (IOException e) {
					// Remove unconnectable
					//ips.remove(ip);
					alert_user("Can not connect to "+pm.ip);
					continue;
				}						
			}
		}
	}
	
	public void streaming_buffer_out(short[] buffer, int length, String groupIdString)
	{
		int groupId = -1;
		int i = 0;
		for(String g:messageGroups)
		{
			if(g.equals(groupIdString))
				groupId = i;
			i++;
		}

		for(ProjectMember pm : ips)
		{
			if(pm != null && pm.ip != null && !pm.ip.equals(getLocalIpAddress()) && pm.groupId == groupId)
			{
				InetSocketAddress clientAddr = new InetSocketAddress(pm.ip,4712);
				Socket client = new Socket();
				try
				{			
					client.connect(clientAddr);
					DataOutputStream dos = new DataOutputStream(client.getOutputStream());
					dos.writeInt(length);
					for(int idx=0;idx<length;idx++)
						dos.writeShort(buffer[idx]);
					client.close();
				} catch (IOException e) {
					// Remove unconnectable
					//ips.remove(ip);
					alert_user("Can not connect to "+pm.ip);
					continue;
				}						
			}
		}
	}		
	
	public void plot_data(Canvas plotCanvas, int width, int height) {}
	
	public void screen_touched(float x, float y) {}
	
	public void streaming_buffer_in(short[] buffer, int length, int senderId)
	{
	}

	public void onMarkerReached(AudioTrack track) {
		// TODO Auto-generated method stub
		
	}

	public void onPeriodicNotification(AudioTrack track) {
		// TODO Auto-generated method stub
		
	}
	
	public void alert_user(String message)
	{
		AlertDialog.Builder builder = new AlertDialog.Builder(frameWork);
		builder.setMessage(message)
		       .setCancelable(false)
		       .setPositiveButton("OK", new DialogInterface.OnClickListener() {
		           public void onClick(DialogInterface dialog, int id) {
		           }
		       });
		AlertDialog alert = builder.create();	
		alert.show();
	}
	
	public void camera_image(byte[] image, int width, int height){}
	public void camera_image_rgb(byte[] image, int width, int height) {}
	
	Bitmap bm = null;

	public void plot_camera_image(Canvas plotCanvas, byte[] image, int imageWidth,int imageHeight, int width, int height)
	{
		if(bm == null)
			bm = Bitmap.createBitmap(imageWidth/8, imageHeight/4, Bitmap.Config.ARGB_8888);

		for(int y = 0;y < imageHeight/4;y++)
			for(int x = 0;x < imageWidth/8;x++)
				{
					int i = (y*4*imageWidth+x*4);
					int greyValue = image[i];
					
					int greyColor = 0xFF000000 | (greyValue<<16)&0xFF0000 | (greyValue<<8)&0xFF00 | greyValue&0xFF;
					bm.setPixel(x, y, greyColor);
				}

			//plotCanvas.drawBitmap(bm, 0, 0, null);
			Rect src = new Rect(0,0,imageHeight/4,imageWidth/8);
			Rect dst = new Rect(0,0,width,height);
			plotCanvas.rotate(90,width/2,height/2);
			plotCanvas.drawBitmap(bm, src, dst, null);
	}

	public void plot_camera_image_rgb(Canvas plotCanvas, byte[] latestRGBImage, int imageWidth,int imageHeight, int width, int height)
	{
		if(bm == null)
			bm = Bitmap.createBitmap(imageWidth/8, imageHeight/4, Bitmap.Config.ARGB_8888);

		for(int y = 0;y < imageHeight/4;y++)
		for(int x = 0;x < imageWidth/8;x++)
			{
				int i = (y*4*imageWidth+x*4)*3;
				
				int rgbColor = 0xFF000000 | (latestRGBImage[i]<<16)&0xFF0000 | (latestRGBImage[i+1]<<8)&0xFF00 | latestRGBImage[i+2]&0xFF;
				bm.setPixel(x,y, rgbColor);
			}

		
		Rect src = new Rect(0,0,imageHeight/4,imageWidth/8);
		Rect dst = new Rect(0,0,width,height);
		plotCanvas.rotate(90,width/2,height/2);
		plotCanvas.drawBitmap(bm, src, dst, null);
	}
	
public boolean test_harness()
{
    return false;
}

public class SimpleInputFile
{
    BufferedReader stream = null;
    public void open(String name)
    {
        String fileName = new 
String(Environment.getExternalStorageDirectory() + "/" + name);
        stream = null;
        try {
            stream = new BufferedReader(new FileReader(fileName));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }
    public void close()
    {
        if(stream == null)
            return;
        try {
            stream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public double readDouble()
    {
        if(stream == null)
            return 0;
        double result = 0;
        try {
            result = Double.valueOf(stream.readLine());
        } catch (IOException e) {
            e.printStackTrace();
        }
        return result;
    }
    public int readInt()
    {
        return (int)readDouble();
    }
    public String readString()
    
    	   {
    	        if(stream == null)
    	            return null;
    	        String result = null;
    	        try {
    	            result = stream.readLine();
    	        } catch (IOException e) {
    	            e.printStackTrace();
    	        }
    	        return result;
    	    }
    

}


public class SimpleOutputFile
{ 
    BufferedWriter stream = null;
    
    public void open(String name)
    {
        String fileName = new 
String(Environment.getExternalStorageDirectory() + "/" + name);
        stream = null;
        try {
            stream = new BufferedWriter(new FileWriter(fileName));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void close()
    {
        if(stream == null)
            return;
        try {
        	stream.flush();
            stream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void writeDouble(double value)
    {
        if(stream == null)
            return;
        try {
            stream.write(""+value+"\n");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public void writeInt(int value)
    {
        if(stream == null)
            return;
        try {
            stream.write(""+value+"\n");
        } catch (IOException e) {
            e.printStackTrace();
        }
     
    }
    public void writeString(String input)
    {
        if(stream == null)
            return;
        try {
            stream.write(""+input+"\n");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
	}

	public String list_ips()  {
	  String list;
      list =new String();
      if (messageGroups==null) {
     	  for(ProjectMember pm : ips)
    	  {			
    		  list=list+pm.ip+"\n";
    	  }
      } else {
     	  for(ProjectMember pm : ips)
    	  {			
    		  list=list+pm.ip+"      "+pm.groupId+"      "+messageGroups[pm.groupId]+"\n";
    	  }    	      	  
    	
      }
      list=list+"This phone="+getLocalIpAddress()+"      "+myGroupID+"      "+messageGroups[myGroupID]+"\n";
      return list; 
	};
	
	public void browseForFile(){ frameWork.openFile(); };
	
	public void open_text_file(String filename){ 
		//AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
		
		File dir = new File(Environment.getExternalStorageDirectory().getPath());
		String filename_with_path = new String(dir+"/"+filename);
		//add_output_text_line("filename="+filename);
		frameWork.open_text_file(filename_with_path); 
		};
};




