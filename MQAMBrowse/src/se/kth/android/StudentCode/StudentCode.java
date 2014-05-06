/* Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
* This software is provided  抋s is�. It is free to use for non-commercial purposes.
* For commercial purposes please contact Peter H鋘del (peter.handel@ee.kth.se)
* for a license. For non-commercial use, we appreciate citations of our work,
* please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
* for how information on how to cite. */ 

package se.kth.android.StudentCode;

import java.io.BufferedReader;
import java.lang.System;
import java.util.ArrayList;
//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Date;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Vector;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.Object;
import android.app.Activity;
import android.os.Vibrator;
import android.content.Context;

import com.google.zxing.Binarizer;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.ChecksumException;
import com.google.zxing.FormatException;
import com.google.zxing.LuminanceSource;
import com.google.zxing.NotFoundException;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Reader;
import com.google.zxing.Result;
import com.google.zxing.ResultPoint;
import com.google.zxing.common.BitArray;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.common.DetectorResult;
import com.google.zxing.common.GlobalHistogramBinarizer;
import com.google.zxing.qrcode.QRCodeReader;
import com.google.zxing.qrcode.detector.Detector;

//import org.apache.commons.net.ntp.TimeInfo;
//import org.apache.commons.net.ntp.TimeStamp;



import se.kth.android.FrameWork.FrameWork;
import se.kth.android.FrameWork.StudentCodeBase;
import se.kth.android.FrameWork.StudentCodeBase.SimpleOutputFile;


import android.annotation.SuppressLint;
import android.content.Context;
//import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.BitmapFactory;
//import android.graphics.Color;
//import android.graphics.Paint;
//import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Paint.Style;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.net.wifi.ScanResult;
import android.os.Environment;
import android.os.Handler;


public class StudentCode extends StudentCodeBase {
	 
    boolean init_done=false;
    boolean file_loaded=false;
    byte[] the_sound_file_contents=null;
    ByteBuffer the_sound_file_contents_bb=null; 
    short buffer[];
    short longBuffer[] = new short[4096*10];
    short delaySamples[] = new short[4096];
    private final int duration = 3; // seconds
    private static final int mysampleRate = 44100;
    private final int numSamples = duration * mysampleRate;
    private final double sample[] = new double[numSamples];
    private final byte generatedSnd[] = new byte[2 * numSamples];
    
    final static int no_samp_period = 8;
    final static int f1=mysampleRate/4;
    final static int f2=7350;
    final static int f3=mysampleRate/7;
    final static int f4=mysampleRate/8;
    final static int ts_f1=mysampleRate/20;
    final static int ts_f2=mysampleRate/15;
    
    int ts_stream[];
    final static double[] cosf1 =initCosine(f1, mysampleRate,no_samp_period);
    final static double[] sinf1 =initSinusoid(f1, mysampleRate,no_samp_period);
    final static int levels = 3;
    final static int A = 1;
    
    double phihat;
    // Initialize cosines with specified frequency used for training sequence transmission
    final static double[] cosf1ts =initCosine(ts_f1, mysampleRate,no_samp_period);
    final static double[] cosf2ts =initCosine(ts_f2, mysampleRate,no_samp_period);
    
    private static final double MAX_16_BIT = Short.MAX_VALUE; 
    private static final int SAMPLE_BUFFER_SIZE = 4096;
    private static byte[] bufferInt;         // our internal buffer
    private static int bufferSize = 0;    // number of samples currently in internal buffer
    private static int bufferLength = 4096; 
    private static final int BYTES_PER_SAMPLE = 2;                // 16-bit audio
    private static final int BITS_PER_SAMPLE = 16;                // 16-bit audio
    
    public static int trigger = 0; //0 -> listening and waiting 1 -> listening and received 2 -> done listening -1 ->processed
    private static short[] rx_buffer;
    private static int rx_ind=0;
    private static int ts_length = 172;//504;
    private static int gb_length = 220;//804;
    private static double[] ts_mod;
    private static double[][] ts_mod_const;
    private static double[] window;
    
    private static int side=-1;
    private static double[] ts_modQAM;
    
    // Variables for functions: int[] data_buffer_bits() and void retrieveData(int[] received)
    byte[] the_file_contents=null;
    ByteBuffer the_file_contents_bb=null;
    int data_buffer_bits[];
    byte data_buffer[];
    int[] receivedBits;
    int[] received_buffer;
    String d_filename;
    int numberBits;
    int[] bit_buffer;
    int state=-1;
	int state_two = 0;
	int[] sizeofFile; 
	int[] titleofFile;
	
	// Variables used in the switch cases
	final int GETDATA = 0; 
	final int RECEIVED = 1;
	final int SEND = 2;
	final int END = 2;
	final int WRITE = 2;
	final int FIRST = 0;
	final int SECOND = 1;
    
	// Variable keeping in track of any errors that might occur
    boolean error = false;
    
    // Variable used for testing
    boolean testing = false;
	
    // Needs to be divisible by 8 and a number that depends on variable levels  
	final int length_titleFile = 768;
	final int length_sizeFile  = 768;
	String rx_filename;
 
    // This is called before any other functions are initialized so that parameters for these can be set
    public void init(int a) //a=0 -> tx ; a=1 -> rx
    { 
    	
           // Name your project so that messaging will work within your project
           projectName = "DemoProject";
           set_output_text("Hello World! Press menu for options!");
           // Add sensors your project will use
           if(a==0){ useSensors =  SOUND_OUT; // CAMERA;CAMERA_RGB;//WIFI_SCAN | SOUND_OUT; //GYROSCOPE;//SOUND_IN|SOUND_OUT;//WIFI_SCAN | ACCELEROMETER | MAGNETIC_FIELD | PROXIMITY | LIGHT;//TIME_SYNC|SOUND_IN;//TIME_SYNC | ACCELEROMETER | MAGNETIC_FIELD | PROXIMITY | LIGHT | SOUND_IN;
           clear_output_text();
           add_output_text_line("TX side");
           side=0;
           }
           if(a==1){ useSensors=SOUND_IN; add_output_text_line("RX side"); side=1; }                               
          
           // Set sample rate for sound in/out, 8000 for emulator, 8000, 11025, 22050 or 44100 for target device
           sampleRate = 44100;
            
           // If CAMERA_RGB or CAMERA, use camera GUI?
           useCameraGUI=false;
           useAutoFocus=true;
          
           // Enable or disable logging of sensor data to memory card
           loggingOn = false;
          
           // If message communication is used between phones in the project, enable it here and set server address, type and group names
           useMessaging = false;   
           messageServer = "192.168.1.102";  
           messageServerType = PHONE_SERVER;//LINUX_MESSAGE_SERVER; // WEB_MESSAGE_SERVER
            
           String temp[] =  {"N1","N2","N3"};
           messageGroups = temp;  
           //messageGroups=null;
              
           // If using time synchronization set the NTP time server address 
           //ntpServer = "192.168.1.5";
           //ntpServer = "192.168.5.11";
                        
           // Set the approximate interval in milliseconds for your need for calls to your process function
           processInterval = 1;
          
           // If you access and modify data structures from several sensor functions and/or process you may need to make the calls
           // be performed in series instead of simultaneous to prevent exception when one function changes data at the same time as another 
           // reads it. If this is the case set useConcurrentLocks to true
           useConcurrentLocks = false;
          
          
           // If you want a text on screen before start is pressed put it here
     
           // Stuff for the playing of sound example
           init_done=true;
           buffer=new short[1024]; // 1024 samples sent to codec at a time
           userInputString=true;
           
           bufferInt = new byte[SAMPLE_BUFFER_SIZE * BYTES_PER_SAMPLE];
           
           // Variable that governs maximum file transfer size
           int length_rxb =no_samp_period*2000*30;
           rx_buffer = new short[length_rxb];
           
           // Specify type of window function, 0 -> rect window, 1 -> Hanning window 
           window =create_window(1);
                     
           // Modulate the training sequence
           ts_modQAM = modulateQAM_ts(ts_length,f1,levels); 
           
           // Line used for debugging purposes
           //add_output_text_line("MQAM f="+f1);
           //d_filename = null;
    }

    // This is called when the user presses start in the menu, reinitialize any data if needed
    public void start()
    {    
    	trigger=0;
    	
    	if(side==0){
    		browseForFile();
    	}
    	
    }
     
    // This is called when the user presses stop in the menu, do any post processing here
    public void stop()      
    {
    	  // The user has the option to open the file received
    	  error = false;
    	  if(side==1) open_text_file(rx_filename);
          trigger=-1;
          rx_ind=0;
          clear_output_text();
          set_output_text("Stopped.");
          side=-1;
          file_loaded=false;
          
    }
     
    // Place your local field variables here
    String triggerTime;
    String gpsData;
    String gyroData;
    String magneticData;
    String proximityData;
    String lightData;
    String screenData;
    String messageData;
    String wifi_ap = "Start value";
   
    // Fill in the process function that will be called according to interval above
    @SuppressLint("NewApi")
	public void process()
    {  
    	
        if(d_filename != null) state=GETDATA; //file has been picked

    	switch(state){
    	
    	// Convert file to be sent into a binary stream stored in bit_buffer
    	case GETDATA:
    		bit_buffer = data_buffer_bits();
    		
    		// Line for debugging purposes
    		//save_i_to_file("bitbuffer.txt",bit_buffer,bit_buffer.length);
    		
    		// If the file is too big start again
    		if (error == true){
    			trigger=-1;
    			state=-1;
    			d_filename = null;
    			bit_buffer = null;
    		}
    		break;
    	    
    	// Send data stored in bit_buffer
    	case SEND:  
    		send_data();
    		
        // Receiver part
    	case RECEIVED:
    	if(trigger==2){
    		add_output_text_line("Stopped listening and started decoding");
    		//useSensors =  SOUND_OUT;
    		int margin = 20;
    		int block_length=2*levels*no_samp_period*(gb_length+ts_length+margin); //block to do cross correlation
    		double[] rx_bufferdouble = new double[rx_ind+4096-rx_ind%4096]; //buffer of doubles
    		// Line used for debugging purposes
    		//add_output_text_line("buffer length="+rx_buffer.length+"rx_ind+ = "+(rx_ind+4096-rx_ind%4096));
    		for (int j=0;j<rx_ind;j++){
    			rx_bufferdouble[j] = (double) rx_buffer[j]; //convert received samples to doubles.
    		}
    		
    		// Line used for debugging purposes
    		//save_d_to_file("rx_signal.txt",rx_bufferdouble,rx_bufferdouble.length);
    		
    		// Equalizer
    		rx_bufferdouble = EQ(rx_bufferdouble); 
    		//save_d_to_file("rx_signal_afterEQ.txt",rx_bufferdouble,rx_bufferdouble.length);
    		//save_to_file("rx_a.txt",rx_bufferdouble,rx_bufferdouble.length);
    		
    		// Time the maxXcorr function
    		long startTime3 = System.currentTimeMillis();
    		int index = maxXcorr(Arrays.copyOfRange(rx_bufferdouble, 0, block_length),ts_modQAM); //find where training sequence begins
    		long endTime3 = System.currentTimeMillis();
    		add_output_text_line("maxXcorr took " + (endTime3 - startTime3) + " milliseconds");
    		
    		//send received data to decision algorithm, copy only data part
    		// Time the MQAMreceiver function
    		long startTime = System.currentTimeMillis();
    		int decision[] = MQAMreceiver(f1,no_samp_period,Arrays.copyOfRange(rx_bufferdouble,index-margin,rx_bufferdouble.length));
    		long endTime = System.currentTimeMillis();
    		add_output_text_line("MAQMreceiver took " + (endTime - startTime) + " milliseconds");

    		// Save decision to file
    		//save_i_to_file("decision.txt", decision,decision.length);

    		// Convert binary stream back into a file
    		// Time the retrieveData function
    		long startTime2 = System.currentTimeMillis();
    		rx_filename = retrieveData(decision);
      	    long endTime2 = System.currentTimeMillis();
  		    add_output_text_line("RetrieveData took " + (endTime2 - startTime2) + " milliseconds");
      	    
  		    if(testing == true){
      	    compare(decision);
      	    }
    		  		
      	   // If an error occurs start again
      	   if (error == true){
      		   trigger=-1;
          	   state=-1;
          	   d_filename = null;
      	   }
      	   else{
      		please_vibrate();
      	    // File is finished transferring
    		add_output_text_line("File is received. If you would like to open "+rx_filename+" now, press the menu button and select open.");
    		
    		// Calculate rate achieved
    		double R = 2*levels *((double) mysampleRate) /( (double) no_samp_period);
    		
    		// Display rate achieved 
    		add_output_text_line("achieved rate = "+R);
    		d_filename = null;
          	bit_buffer = null;
    		trigger=-1;
    		state=-1;
      	   }

    	}
    	}

    };       

   
  

	// Fill in the functions receiving sensor data to do processing 
    public void gps(long time, double latitude, double longitude, double height, double precision)
    {
           gpsData = "G: "+format4_2.format(latitude)+":"+format4_2.format(longitude)+":"+format4_2.format(height)+":"+format4_2.format(precision);
    }
   
    public void magnetic_field(long time, double x, double y, double z)
    {
           magneticData = "M: "+format4_2.format(x)+":"+format4_2.format(y)+":"+format4_2.format(z);
    }

    public void accelerometer(long time, double x, double y, double z)
    {
           triggerTime = "A: "+format4_2.format(x)+":"+format4_2.format(y)+":"+format4_2.format(z);
    }
   
    public void gyroscope(long time, double x, double y, double z)
    {
           gyroData = "G: "+format4_2.format(x)+":"+format4_2.format(y)+":"+format4_2.format(z);
    }
    public void proximity(long time, double p)
    {
           proximityData = "P: "+format4_2.format(p); 
    }
   
    public void light(long time, double l)
    {
           lightData = "L: "+format4_2.format(l);
    }
   
    void echoPlay(final short[] samp, int len)
    {
           final Handler handler = new Handler();
           handler.postDelayed(new Runnable() {
              @Override
              public void run() {
                  // Do something after 5s = 5000ms
                  sound_out(samp,samp.length);
              }
           }, 1000);
          
    }
   
    @SuppressLint("NewApi")
	public void sound_in(long time, final short[] samples, int length)
    { 
    	final int threshold = 100;
    	int continue_listening = 0; //variable to verify if transmission is done (detect only noise in buffer)
    	if(trigger==0){
    	set_output_text("only noise for the moment");
    	for(int i = 0 ; i < length; i++){
    		if(i==10){
    			add_output_text_line("sample_amp="+samples[i]);
    		}
    		if(samples[i]>threshold){
    			clear_output_text();
    			trigger=1;
    			add_output_text_line("started listening");
    			rx_buffer=send_to_buffer(rx_buffer,length-i,Arrays.copyOfRange(samples, i, length));
    			break;
    	}
    	}
    	}else{
    		if(trigger==1){
    			for(int i = 0;i<samples.length;i++){
    				if(samples[i]>threshold) { continue_listening = 1; break;}
    			}
    			if(continue_listening==1){
    		rx_buffer=send_to_buffer(rx_buffer,length,samples);
    			}else{ //buffer of only noise, transmission done
    				 trigger=2;
    				 state=RECEIVED;
    			}
    			
    			}
    	}
    
    }
    
    	
  
    public void screen_touched(float x, float y) 
    {
    } 
            
    // Implement your phone to phone receive messaging here
    public void message_in(StudentMessage message)
    {
    }           
    // Implement any plotting you need here 
    public void plot_data(Canvas plotCanvas, int width, int height) 
    {           
          
           if((latestImage != null) && ((useSensors & CAMERA) == CAMERA)) // If camera is enabled, display
           {
                  plot_camera_image(plotCanvas,latestImage,imageWidth,imageHeight,width,height);
           }                         
           if((latestRGBImage != null) && ((useSensors & CAMERA_RGB) == CAMERA_RGB)) // If camera is enabled, display
           {
                  plot_camera_image_rgb(plotCanvas,latestRGBImage,imageWidth,imageHeight,width,height);
           }                         
    }
    
	public void stringFromBrowseForFile(String filename){
		// Store name and extension of file in d_filename
		d_filename=filename;
		// Display file chosen for sending
		add_output_text_line("You chose "+d_filename+" for sending.");
	}
   
    public void stringFromUser(String user_input)
    {
    	if (side==-1) {

    		//set_output_text(user_input);
        	String MessageFromUser = "MessageFromUser.txt";
    		
        	// Save string from user to a text file
        	save_to_file_s(MessageFromUser,user_input,user_input.length());
        	add_output_text_line("The file "+MessageFromUser+" was stored on the phone.");
    	}
    	else{
        	// Opens received file
        	open_text_file(user_input);
    	}
    }

   
    // Implement wifi ap analysis here
    public void wifi_ap(long time, List<ScanResult> wifi_list)
    {
           wifi_ap = "";
           for(ScanResult sr: wifi_list)
                  wifi_ap += sr.SSID + " " + sr.level + "\n"; 
          
    }

    // Implement reception of streaming sound here
    public void streaming_buffer_in(short[] buffer, int length, int senderId)
    {
    }

    byte[] latestImage = null;
    byte[] latestRGBImage = null;
    int imageHeight = 0;
    int imageWidth = 0;
    QRCodeReader r = new QRCodeReader();
   
    public void camera_image(byte[] image, int width, int height) // For gray scale G8 in each byte
    {
           /* Save latest image*/
           latestImage = image;
           imageWidth = width;
           imageHeight = height;

    }
   


    public void camera_image_rgb(byte[] image, int width, int height) // For color RGB888 interleaved
    {
           latestRGBImage = image;
           imageWidth = width;
           imageHeight = height;
                          
           /* Below is example code which uses the com.google.zxing.qrcode QR decoder to
             detect a web address. The address is displayed in the text display. */
           /* zxing start color */ 
          
           Result res = null;
           int[] frame = new int[width/4*height/4];
           for(int y=0;y<height/4;y++)
                  for(int x=0;x<width/4;x++)
                  {
                         int i = (y*4*width+x*4)*3;
                        
                         int rgbColor = 0xFF000000 | (image[i]<<16)&0xFF0000 | (image[i+1]<<8)&0xFF00 | image[i+2]&0xFF;
                         frame[y*width/4+x] = rgbColor;
                  }
                                      
                 
          
           RGBLuminanceSource s = new RGBLuminanceSource(width/4,height/4,frame);
           BinaryBitmap b = new BinaryBitmap(new GlobalHistogramBinarizer(s));
           Detector d;
           DetectorResult dr = null;
           try {
                  d = new Detector(b.getBlackMatrix());
                  dr = d.detect();
                 
                  res = r.decode(b);
           } catch (NotFoundException e) {
           } catch (FormatException e) {
           }
       catch (ChecksumException e) {
       }
           if(dr != null)
           for(ResultPoint rp : dr.getPoints())
           {
                  image[(int) ((rp.getX()*4+rp.getY()*4*width)*3)] = 0;
                  image[(int) ((rp.getX()*4+rp.getY()*4*width)*3)+1] = 0;
                  image[(int) ((rp.getX()*4+rp.getY()*4*width)*3)+1] = (byte) 0xFF;
           }
          
           if(res != null)
           {
                  set_output_text(res.getText());
           } 
          
           /* zxing stop color */ 
    }


 //This function is called before the framework executes normally  meaning that no sensors or
 // initialing is done.
 // If you return true the execution stops after this function.
 // Use this to test algorithms with static data.
 public boolean test_harness()
 {
    boolean do_test=false; // Set to true when running test_harness_example
   
  // The below code is used together with test_harness_example.m.  
 if (do_test) {  
    int no_of_real=5000;
    double [] in_values = new double[no_of_real];
    int [] out_values;
   // in_values=new double[no_of_real];
// for(int k=0;k<no_of_real;k++){
//	in_values[k]=Math.random()*2+5;
//}
	
    SimpleOutputFile out = new SimpleOutputFile();
    SimpleInputFile in = new SimpleInputFile();
   
    in.open("indata.txt");             
    out.open("outdata.txt");
   
    // Read data from input file 
    no_of_real=in.readInt();
    
    // Read file from sdcard
    for(int i=0; i<in_values.length; i++){
           in_values[i]=in.readDouble(); 
    };
    int f1=200;
    int f2=300;	
    int n=100;
     // Call the function to be tested 
   // out_values=goertzel(f1,f2,n,in_values);
   
    // Write file on sdcard 
    //for(int i=0; i<out_values.length; i++){
        //   out.writeDouble(out_values[i]);
   // };
            
    
    out.close();  
    in.close();
   
    return true;
 } else
 return false;
}

/* Used in test_harness_example.m */
private double [] square(double [] in_values) {
    double [] out_values;
    out_values = new double[in_values.length];
    for(int i=0; i<in_values.length; i++){
           out_values[i]=in_values[i]*in_values[i];
    } 
    return out_values;
}


    public void playsoundexample(){
           if (init_done && (!file_loaded)) {
                  the_sound_file_contents=read_data_from_file("lga.dat"); // Read file from plain file of samples in form of shorts
                  the_sound_file_contents_bb=ByteBuffer.wrap(the_sound_file_contents); // Wrapper to easier access content.
                  the_sound_file_contents_bb.order(ByteOrder.LITTLE_ENDIAN);
                  file_loaded=true;
                  set_output_text("length="+the_sound_file_contents.length);
           };
          
           if (file_loaded) {
                  if (the_sound_file_contents_bb.remaining()<2*buffer.length)
                         the_sound_file_contents_bb.rewind(); // Start buffer from beginning
                  for (int i1=0;i1<buffer.length;i1++) {                        
                         buffer[i1]=the_sound_file_contents_bb.getShort(); // Create a buffer of shorts
                  };
                  sound_out(buffer,buffer.length); // Send buffer to player                    
           };            
    };
    
//Task 3 generate a mono tone of specified frequency
 void genTone(int freq){
     // fill out the array
     for (int i = 0; i < numSamples; ++i) {
         sample[i] = Math.sin(2 * Math.PI * i / (mysampleRate/freq));
     }

     // convert to 16 bit pcm sound array
     // assumes the sample buffer is normalised.
     int idx = 0;
     for (final double dVal : sample) {
         // scale to maximum amplitude
         final short val = (short) ((dVal * 10767));
         // in 16 bit wav PCM, first byte is the low order byte
         generatedSnd[idx++] = (byte) (val & 0x00ff);
         generatedSnd[idx++] = (byte) ((val & 0xff00) >>> 8);

     }
 }

 void playSound(){
     final AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC,
             mysampleRate, AudioFormat.CHANNEL_OUT_MONO,
             AudioFormat.ENCODING_PCM_16BIT, generatedSnd.length,
             AudioTrack.MODE_STREAM);
     audioTrack.write(generatedSnd, 0, generatedSnd.length);
     audioTrack.play();
 }
 
 void square(int sample){
	 double Q=Math.sqrt(sample);
	 set_output_text(""+sample+"\n"+Q+ "\n");
}
 
 // Function used to compute FFT
 public static Complex[] fft(Complex[] x) {
     int N = x.length;

     // base case
     if (N == 1) return new Complex[] { x[0] };

     // radix 2 Cooley-Tukey FFT
     if (N % 2 != 0) { throw new RuntimeException("N is not a power of 2"); }

     // fft of even terms
     Complex[] even = new Complex[N/2];
     for (int k = 0; k < N/2; k++) {
         even[k] = x[2*k];
     }
     Complex[] q = fft(even);

     // fft of odd terms
     Complex[] odd  = even;  // reuse the array
     for (int k = 0; k < N/2; k++) {
         odd[k] = x[2*k + 1];
     }
     Complex[] r = fft(odd);

     // combine
     Complex[] y = new Complex[N];
     for (int k = 0; k < N/2; k++) {
         double kth = -2 * k * Math.PI / N;
         Complex wk = new Complex(Math.cos(kth), Math.sin(kth));
         y[k]       = q[k].plus(wk.times(r[k]));
         y[k + N/2] = q[k].minus(wk.times(r[k]));
     }
     return y;
 }
 
 public static int[] goertzel(int f1, int f2, int n, double r[]){
	 double fs=44100;
	 
	 double k1=0.5+ (double) (n*f1)/ ((double) fs);
	 double k2=0.5+ (double) (n*f2)/ ((double) fs);
	 
	 double coeff1=2*Math.cos(2 * Math.PI / n * k1);
	 double coeff2=2*Math.cos(2 * Math.PI / n * k2);
	 double[] P =new double[3];
	 double[] Q =new double[3];
	 double[] mag1 =new double[r.length/n];
	 double[] mag2 =new double[r.length/n];
	 int aux=0;
	 
	 for(int l=0;l<r.length;l++) {
		 P[0]=coeff1*P[1]-P[2]+r[l];
		 Q[0]=coeff2*Q[1]-Q[2]+r[l];
		 Q[2]=Q[1]; Q[1]=Q[0];
		 P[2]=P[1]; P[1]=P[0];
		 	
		 if((l+1)%n==0){
			 mag1[aux]=P[1]*P[1]+P[2]*P[2]-P[1]*P[2]*coeff1;
			 mag2[aux]=Q[1]*Q[1]+Q[2]*Q[2]-Q[1]*Q[2]*coeff2;
			 aux++;
			//reset
			 Q[2]=0;Q[1]=0;Q[0]=0;
			 P[2]=0;P[1]=0;P[0]=0;
		 }
			
		 
	 }
	 
	 int[] decision= new int[aux+8-aux%8];
	 
	 for(int l=0;l<aux;l++){
		 if(mag1[l]>mag2[l]){
			 decision[l]=1;
		 }else{
			 decision[l]=0;
		 }
	 }
 	 return decision;
	 
 }
 
 public int maxXcorr(double[] x,double[] y){
	 double[] c= new double[x.length-y.length+2];
	 double maxc=0;
	 int index=0;
	 for(int i = 0; i < x.length-y.length+1;i++){
		 c[i]=0;
		 for(int ii=0;ii<y.length-1;ii++){
			 c[i]=c[i]+x[ii+i]*y[ii];
		 }
	 }
	 
	 for(int i=0;i<c.length;i++){
		 if(c[i]>maxc){
			 index=i;
			 maxc=c[i];
		 }
	 }
	 //add_output_text_line("index="+index);
	 return index;
 }
 

//Modulation function into 2FSK used to modulate the training sequence
 public static double[] FSK_mod_ts(int f1,int f2, int[] r){
	 double[] signal = new double[no_samp_period*r.length];

	 for(int i=0;i<r.length;i++){
		 if(r[i]==1){
			 for(int ii=i*no_samp_period;ii<no_samp_period*(i+1)-1;ii++){
				 signal[ii]=cosf1ts[ii-i*no_samp_period];
			 }
		 }
		 else{
			 for(int ii=i*no_samp_period;ii<no_samp_period*(i+1)-1;ii++){
				 signal[ii]= cosf2ts[ii-i*no_samp_period];
			 }
		 }

	 }
	 return signal;
 }
 
//Initialize cosine with specified frequency
 public static double[] initCosine(int f, int fs,int N){
	 double cosf[]=new double[N];
	 for(int k=0;k<N;k++){
		 cosf[k] = Math.cos(2 * Math.PI * (double) f * (double) k / ((double) fs));
	 }
	 return cosf;
 }
 
//Initialize sine with specified frequency
 public static double[] initSinusoid(int f, int fs,int N){
	 double sinf[]=new double[N];
	 for(int k=0;k<N;k++){
		 sinf[k] = Math.sin(2 * Math.PI * (double) f * (double) k / ((double) fs));
	 }
	 return sinf;
 }
 
void send_data(){
	// Generate a random stream of bits for testing
	
	SimpleInputFile in = new SimpleInputFile();
    //in.open("data_test.txt"); 
    //int Nb=in.readInt();
    //int[] bit_stream = new int[Nb];
	

	//int[] size_data_signal = new int [100];
//	for(int i = 0;i<Nb;i++){
//		bit_stream[i]=Math.round((float) Math.random());
//		}
	//for(int i = 0;i<Nb;i++){
	//bit_stream[i]=in.readInt();
	//}
	//in.close();
	
	in.open("gb_test.txt");
	gb_length = in.readInt();
	
	// Line for debugging purposes
	//add_output_text_line("gb_length="+gb_length);
	
	int[] guard_stream = new int[gb_length*2*levels];
	for(int i = 0;i<gb_length*2*levels;i++){
		guard_stream[i]=in.readInt();
		//guard_stream[i]=Math.round((float) Math.random());
	}
	in.close();
//	bit_stream = load_from_file("data_test.txt",Nb);
//	save_to_file("data.txt",bit_stream,Nb);
	
	// Modulate the guard and data signal
	double[] guard_signal =  MQAMmod(f1,guard_stream);
	double[] data_signal = MQAMmod(f1,bit_buffer);
	double[] size_data_signal = MQAMmod(f1,sizeofFile);
	double[] title_data_signal = MQAMmod(f1,titleofFile);
	
	// Size of total signal to be transmitted
	double[] tx_signal =new double[2*guard_signal.length+data_signal.length+ts_modQAM.length+bufferInt.length+title_data_signal.length+size_data_signal.length];
	
	int current_position=0;
	
	for(int i=0;i<guard_signal.length;i++){
		tx_signal[current_position]=guard_signal[i];
		current_position++;
	}
	for(int i=0; i<ts_modQAM.length; i++){
		tx_signal[current_position]=ts_modQAM[i];
		current_position++;
	}
	for(int i=0; i<title_data_signal.length; i++){
		tx_signal[current_position]=title_data_signal[i];
		current_position++;
	}
	for(int i=0; i<size_data_signal.length; i++){
		tx_signal[current_position]=size_data_signal[i];
		current_position++;
	}
	for(int i=0;i<data_signal.length;i++){
		tx_signal[current_position]=data_signal[i];
		current_position++;
	}
	for(int i=0;i<guard_signal.length;i++){
		tx_signal[current_position]=guard_signal[i];
		current_position++;
	}
//	for(int i=0;i<bufferInt.length-current_position%bufferInt.length+1;i++){
//		tx_signal[current_position+i]=0;
//	}
//	
	
	
//	current_position = 0;
//	int[] long_stream = new int[guard_stream.length*2+ts_length*2*levels+bit_stream.length];
//	for(int k=0;k<guard_stream.length;k++){
//		long_stream[current_position++]=guard_stream[k];
//		
//	}
//	for(int k=0;k<ts_stream.length;k++){
//		long_stream[current_position++]=ts_stream[k];
//		
//	}
//	for(int k=0;k<bit_stream.length;k++){
//		long_stream[current_position++]=bit_stream[k];		
//	}
//	for(int k=0;k<guard_stream.length;k++){
//		long_stream[current_position++]=guard_stream[k];
//		
//	}
	
	//double tx_signal_c[] = MQAMmod_c(f1,long_stream);
	
	
	final AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC,
            mysampleRate, AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT, bufferInt.length,
            AudioTrack.MODE_STREAM);
	
    //double time_tx= (tx_signal.length) /((double) mysampleRate);
	
	//add_output_text_line("Transmission will take "+Math.round(time_tx*100)/100.00+ " seconds.");
	
	// Find maximum value of tx_singal
	double max = 0;
	for(int i = 0;i<tx_signal.length;i++){
		if(Math.abs(tx_signal[i])>max) max=Math.abs(tx_signal[i]);
	}
	
	//short[] tx_signal_s=new short[tx_signal.length];
	save_d_to_file("tx_signal.txt",tx_signal,tx_signal.length);
	for (int i = 0; i < tx_signal.length; i++) {
		//tx_signal_s[i]=(short) ( tx_signal[i]*Math.pow(2, 14));
		tx_signal[i]=tx_signal[i]/max;
		play(tx_signal[i], audioTrack);
	}
	
	
//	max = 0;
//	for(int i = 0;i<tx_signal_c.length;i++){
//		if(Math.abs(tx_signal_c[i])>max) max=Math.abs(tx_signal_c[i]);
//	}
//	for (int i = 0; i < tx_signal_c.length; i++) {
//		tx_signal_c[i]=tx_signal_c[i]/max;
//
//		//tx_signal_s[i]=(short) ( tx_signal[i]*Math.pow(2, 14));
//
//		play(tx_signal_c[i], audioTrack);
//	}
	
	
//	byte[] sound_contents = double2Byte(tx_signal);
//	ByteBuffer sound_contents_bb;
//	short[] buffer1 = new short[sound_contents.length/8];
//	sound_contents_bb = ByteBuffer.wrap(sound_contents);
//	sound_contents_bb.order(ByteOrder.LITTLE_ENDIAN);
//	for (int i1=0;i1<sound_contents.length/8;i1++) {                        
//		buffer1[i1]=sound_contents_bb.getShort(); // Create a buffer of shorts
//	};
//	 sound_out(tx_signal_s,tx_signal_s.length); // Send buffer to player    

	add_output_text_line("done with buffering of transmission");
	state=-1;
	//d_filename = null;

}

public void play(double in, AudioTrack at) {

    // clip if outside [-1, +1]
    if (in < -1.0){ add_output_text_line("I am clipping"); in = -1.0;}
    if (in > +1.0){  add_output_text_line("I am clipping"); in = +1.0;}

    // convert to bytes
    short s = (short) ( MAX_16_BIT * in);
    bufferInt[bufferSize++] = (byte) s;
    bufferInt[bufferSize++] = (byte) (s >> 8);   // little Endian

    // send to sound card if buffer is full        
    if (bufferSize >= bufferInt.length ) {
    	
    	at.write(bufferInt, 0, bufferInt.length);
        bufferSize = 0;
        at.play();
    }
}

public  short[] send_to_buffer(short[] rx_buffer, int length, short[] samples) {
	//copy buffer
	for(int i=0;i<length;i++){
		rx_buffer[i+rx_ind]=samples[i];
	}
	if(rx_ind+2*length<=rx_buffer.length){
		rx_ind=rx_ind+length;
	}else{
		add_output_text_line("reached the end of buffer");
		trigger=2;
		rx_ind=rx_ind+length;
	}
	return rx_buffer;
}

public double[] modulate_ts(int length, int f1, int f2){
	
	SimpleInputFile in = new SimpleInputFile();
    in.open("ts.txt"); 
	final int [] ts = new int[length];
	   // Read file from sdcard
    for(int i=0; i<ts.length; i++){
           ts[i]=in.readInt(); 
    };
   //add_output_text_line("ts(0,1)="+ts[0]+""+ts[1]);
    in.close();
	final double[] mod_ts =FSK_mod_ts(f1,f2,ts);
	
	return mod_ts;
}

// Function that saves double to a text file
public void save_d_to_file(String filename,double[] data,int length){
	SimpleOutputFile out = new SimpleOutputFile();
	out.open(filename);
	out.writeInt(length);
	for(int i=0; i<length; i++){
      out.writeDouble(data[i]);
	}
	out.close();
	
	
}

// Function that saves int to a text file
public void save_i_to_file(String filename,int[] data,int length){
	SimpleOutputFile out = new SimpleOutputFile();
	out.open(filename);
	out.writeInt(length);
	for(int i=0; i<length; i++){
      out.writeInt(data[i]);
	}
	out.close();
	
	
}

// Function that saves complex to a text file
public void save_c_to_file(String filename,Complex[] data,int length){
	SimpleOutputFile out = new SimpleOutputFile();
	out.open(filename);
	out.writeInt(length);
	for(int i=0; i<length; i++){
      out.writeDouble(data[i].re());
      out.writeDouble(data[i].im());
	}
	out.close();
	
	
}

// Function that saves string to a text file
public void save_to_file_s(String filename,String data,int length){
	
	SimpleOutputFile out = new SimpleOutputFile();
	out.open(filename);
	//out.writeInt(length);
	//for(int i=0; i<data.length; i++){
    out.writeString(data);//[i]);
	//}
	out.close();
}

// Function that reads data from a text file
public int[] load_from_file(String filename,int mode){
	 
	SimpleInputFile in = new SimpleInputFile();
	in.open(filename);  
	int[] length=new int[1];
	length[0] = in.readInt(); 
	if(mode==0) return length;
    int[] in_values = new int[length[0]];
   
    // Read file from sdcard
    for(int i=0; i<in_values.length; i++){
           in_values[i]=in.readInt(); 
    };
    return in_values;
	
}

// Function used to compare received data with text file data
public void compare(int decision[]){
	int[] length_vec=load_from_file("data_test.txt",0);
	float length = length_vec[0];
	//add_output_text_line("length of tx_seq"+length);
	int tx_seq[];
	tx_seq=load_from_file("data_test.txt",1);
	float e = 0;
	float max = 0;
	if(decision.length<length){
		add_output_text_line("decision is smaller than transmitted !!");
		max = decision.length; }
	else{ max = length;
	}
	
	for (int a = 0; a < max; a++) {

        if (tx_seq[a] == decision[a]) {
           // e=e;
            } else {
            e++;
        }
	}
	double BER =e/max;
	add_output_text_line("errors,BER="+e+"  ,  "+BER);
	please_vibrate();
}

//Function that converts as file into a binary stream of ones and zeros
public int[] data_buffer_bits(){
	if (init_done && (!file_loaded) && (!(d_filename==null))) {

		// Read file from plain file of samples in form of shorts
		the_file_contents=read_data_from_file(d_filename);

		// Store length of file in in int[] of bits
		String sizeofFile_s = Integer.toBinaryString(the_file_contents.length);
		
		// Calculate the integer value of the length of the file contents
		int sizeofFile_i = Integer.valueOf(the_file_contents.length);
	/*	
		if (sizeofFile_i>10240){
			add_output_text_line("The file is too big (over 10kB). Please press stop and send a smaller file.");
			error = true;
			return null;
		}
    */
		byte[] sizeofFile_b = sizeofFile_s.getBytes();
		sizeofFile = new int[length_sizeFile];
		for (int k=0;k<sizeofFile_b.length;k++) {				
			for (int k1=0; k1<8; k1++){
				// Turn each byte into its corresponding bit representation
				sizeofFile [8*k+k1]=(sizeofFile_b[k] >> (7-k1) & 1);
			}
		}

		// Store name and extension, d_filename, in int[] of bits
		byte[] titleofFile_b = (d_filename.getBytes());	
		titleofFile = new int[length_titleFile];
		for (int k=0;k<titleofFile_b.length;k++) {				
			for (int k1=0; k1<8; k1++){
				// Turn each byte into its corresponding bit representation
				titleofFile [8*k+k1]=(titleofFile_b[k] >> (7-k1) & 1);
			}
		}

		// Line for debugging purposes
		//add_output_text_line("size of chosen file = "+sizeofFile_s+" (length = "+the_file_contents.length+"bytes)");
		//add_output_text_line("title of chosen file="+d_filename);

		// Convert the data in file to bits
		the_file_contents_bb=ByteBuffer.wrap(the_file_contents); // Wrapper to easier access content.
		the_file_contents_bb.order(ByteOrder.LITTLE_ENDIAN);
		file_loaded=true;
	};

	if (file_loaded){

		// Number of bits is 8 times the byte buffer length
		numberBits = 8*the_file_contents.length;
		data_buffer_bits = new int[numberBits];
		data_buffer = new byte [the_file_contents.length];

		for (int k=0;k<the_file_contents.length;k++) {				

			// Extract each byte from buffer
			data_buffer[k]=the_file_contents_bb.get(k); 
			for (int k1=0; k1<8; k1++){
				// Turn each byte into its corresponding bits
				data_buffer_bits[8*k+k1]=(data_buffer[k] >> (7-k1) & 1);
			};
		}
	};
	
	// When the file is converted to bits, set state to send
	state=SEND;
	d_filename=null;
	
	// Return bits
	return data_buffer_bits;	
}

//Function that converts binary stream of ones and zeros into the original file
public String retrieveData(int[] received){

	byte[] data_buffer_received = new byte[received.length/8];
	int receivedBitstemp[] = new int [8];

	// Line for debugging purposes
	//add_output_text_line("received length / 8 ="+((double) received.length/8)+"rx length"+received.length);

	state_two=FIRST;

	//Convert bits to bytes, note: LITTLE_ENDIAN
	switch(state_two){

	case FIRST:

		for (int k=0;k<received.length/8;k++){
			StringBuilder concatenated = new StringBuilder(8);
			
			// Extract eight bits at a time
			for (int k1=0;k1<8;k1++){
				receivedBitstemp[k1]=received[8*k+k1];
				concatenated.append(receivedBitstemp[k1]);
			}
			
			// Store the eight bits in a string
			String data_concatenated = concatenated.toString();

			try {
				// Converts eight bits at a time into their corresponding byte value
				data_buffer_received[k]= (byte) Integer.parseInt(data_concatenated,2);
			} catch (NumberFormatException e) {
				//e.printStackTrace();
				add_output_text_line("Something went wrong. Please try again.");
				error = true;
				return null;
			}

		}

		state_two = 1;

	case SECOND:

		// Get title of file
		byte[] data_buffer_received_title = new byte[length_titleFile/8];
		for (int k=0;k<length_titleFile/8;k++){
		    if(data_buffer_received[k]!=0){
				data_buffer_received_title[k]=data_buffer_received[k];
			}
		}
		
		// Get title of file
		//byte[] data_buffer_received_title = new byte[length_titleFile/8];
		//int temp_index = 0;
		//while (data_buffer_received[temp_index]!=0){
		//		data_buffer_received_title[temp_index]=data_buffer_received[temp_index];
		//}
		
		// Get size of file
		byte[] data_buffer_received_size = new byte[length_sizeFile/8];
		int counter=length_titleFile/8;
		while(data_buffer_received[counter]!=0){
			data_buffer_received_size[counter-length_titleFile/8]=data_buffer_received[counter];
			counter++;
		}
		
		// Turn size of file into a string
		String data_buffer_received_size_c="";
		for (int k=length_titleFile/8;k<counter;k++){
			data_buffer_received_size_c += (char) data_buffer_received_size[k-length_titleFile/8];
		}
		
		// Turn size of file into a byte
		int size_i;
		try {
			size_i= Integer.parseInt(data_buffer_received_size_c,2);
		} catch (NumberFormatException e) {
			//e.printStackTrace();
			add_output_text_line("Something went wrong. Please try again.");
			error = true;
			return null;
		}
		
		// Get data, remove size and title of file from the received buffer
		//byte[] data_buffer_received_n = new byte[(received.length/8)-(length_titleFile+length_sizeFile)/8];
		byte[] data_buffer_received_n = new byte[(received.length/8)-(length_titleFile+length_sizeFile)/8];
		for (int k=(length_titleFile+length_sizeFile)/8;k<(length_titleFile+length_sizeFile)/8+size_i;k++){
			data_buffer_received_n[k-(length_titleFile+length_sizeFile)/8]=data_buffer_received[k];
		}
		
		// Remove zeros at the end
		int counter_two = 0;
		byte[] data_buffer_received_nn = new byte[size_i];
		
	//	while(data_buffer_received_n[counter_two]!=0){
	//	//for (int k=(length_titleFile+length_sizeFile)/8;k<(length_titleFile+length_sizeFile)/8+size_i;k++){ //received.length/8
	//		data_buffer_received_nn[counter_two]=data_buffer_received_n[counter_two];
	//		counter_two++;
	//	}
		
		for (int i=0;i<size_i;i++){
			//for (int k=(length_titleFile+length_sizeFile)/8;k<(length_titleFile+length_sizeFile)/8+size_i;k++){ //received.length/8
				data_buffer_received_nn[i]=data_buffer_received_n[i];
			}

		// Convert the buffer containing the title into characters
		String data_buffer_received_title_n="";
		String data_buffer_received_ext="";
		
		// Separate the title and the extension
		counter=0;
		
		// Get title of file
		while (data_buffer_received_title[counter]!=46){
			data_buffer_received_title_n += (char) data_buffer_received_title[counter];
			counter++;
		}
		
		// Get extension of file
		int index_t = counter+1;
		while(data_buffer_received_title[index_t]!=0){
			data_buffer_received_ext += (char) data_buffer_received_title[index_t];
			index_t++;
		}
		
		//add_output_text_line("Title of received file = "+data_buffer_received_title_n);

		// Create file
		FileOutputStream outFile;		
		File out = new File(Environment.getExternalStorageDirectory().getPath());

		// The file name to be written and stored
		String filename_title = new String(out+"/"+data_buffer_received_title_n+"."+data_buffer_received_ext);
		String filename_w_ext =new String(data_buffer_received_title_n+"."+data_buffer_received_ext);

		try {
			File file = new File(out+"/"+data_buffer_received_title_n+"."+data_buffer_received_ext);
			//long fileLength = file.length();
			outFile = new FileOutputStream(file);
			// Write the data of received buffer
			outFile.write(data_buffer_received_nn);
			//outFile.flush();
			outFile.close();
		} catch (IOException e) {
			e.printStackTrace();
		};
		return filename_w_ext;
	}
	return null;
}

public void readFile(String received)
{
	SimpleInputFile in = new SimpleInputFile();
	in.open(received);
	String result = in.readString();
	while(result != null){
		//add_output_text_line("line="+result);
		result = in.readString();
	}
}

public static int[] goertzel2(int f1, int f2, int f3, int f4, int n, double r[]){
	 int fs=44100;
	 
	 double k1=0.5+ n*f1/fs;
	 double k2=0.5+ n*f2/fs;
	 double k3=0.5+ n*f3/fs;
	 double k4=0.5+ n*f4/fs;
	 
	 double coeff1=2*Math.cos(2 * Math.PI / n * k1);
	 double coeff2=2*Math.cos(2 * Math.PI / n * k2);
	 double coeff3=2*Math.cos(2 * Math.PI / n * k3);
	 double coeff4=2*Math.cos(2 * Math.PI / n * k4);
	 
	 double[] P =new double[3];
	 double[] Q =new double[3];
	 double[] R =new double[3];
	 double[] S =new double[3];
	 
	 double[] mag1 =new double[r.length/n];
	 double[] mag2 =new double[r.length/n];
	 double[] mag3 =new double[r.length/n];
	 double[] mag4 =new double[r.length/n];
	 int aux=0;
	 
	 for(int l=0;l<r.length;l++) {
		 P[0]=coeff1*P[1]-P[2]+r[l];
		 Q[0]=coeff2*Q[1]-Q[2]+r[l];
		 R[0]=coeff3*R[1]-R[2]+r[1];
		 S[0]=coeff4*S[1]-S[2]+r[1];
		 
		 Q[2]=Q[1]; Q[1]=Q[0];
		 P[2]=P[1]; P[1]=P[0];
		 R[2]=R[1]; R[1]=R[0];
		 S[2]=S[1]; S[1]=S[0];
		 	
		 if((l+1)%n==0){
			 mag1[aux]=P[1]*P[1]+P[2]*P[2]-P[1]*P[2]*coeff1;
			 mag2[aux]=Q[1]*Q[1]+Q[2]*Q[2]-Q[1]*Q[2]*coeff2;
			 mag3[aux]=R[1]*R[1]+R[2]*R[2]-R[1]*R[2]*coeff3;
			 mag4[aux]=S[1]*S[1]+S[2]*S[2]-S[1]*S[2]*coeff4;
			 aux++;
			//reset
			 Q[2]=0;Q[1]=0;Q[0]=0;
			 P[2]=0;P[1]=0;P[0]=0;
			 R[2]=0;R[1]=0;R[0]=0;
			 S[2]=0;S[1]=0;S[0]=0;
		 }
			
		 
	 }
	 
	 int[] decision= new int[aux];
	 
	 for(int l=0;l<aux;l++){
			 
			 ArrayList <Double> v = new ArrayList <Double>();

			    v.add(new Double(mag1[l]));
			    v.add(new Double(mag2[l]));
			    v.add(new Double(mag3[l]));
			    v.add(new Double(mag4[l]));
			    Double value = Collections.max(v);
			    // Might need a += instead
			    if(value==mag1[l]){
			    	decision[l]=Integer.parseInt("00");
			    }
			    else if(value==mag2[l]){
			    	decision[l]=Integer.parseInt("10");
			    }
			    else if(value==mag3[l]){
			    	decision[l]=Integer.parseInt("11");
			    }
			    else if(value==mag4[l]){
			    	decision[l]=Integer.parseInt("01");
			    }
	 }
	 return decision;
	 
}

public static double[][] mod_const(int bit_stream[], int L,int levels){
	double xi = 0;
	double yi = 0;
	double mconst[][] =new double[((int) ( (double) L/((double) 2*levels)*no_samp_period))][2];
	int current_position=0;
	
	
	for(int n=0;n<=L-2*levels;n=n+2*levels){
		xi=0;
		yi=0;
		for(int m=0;m<2*levels;m=m+2){
			if(bit_stream[n+m]==0){      
				xi=xi+A*Math.pow(2, m/2);

			}else{
				xi=xi-A*Math.pow(2, m/2);
			}     
			if(bit_stream[n+m+1]==0){
				yi=yi+A*Math.pow(2, m/2);

			}else{
				yi=yi-A*Math.pow(2, m/2);
			}


		}

		for(int k=0;k<no_samp_period;k++){
			mconst[current_position+k][0]=1*xi;
		}

		for(int k=0;k<no_samp_period;k++){
			mconst[current_position+k][1]=1*yi;
		}

		current_position=current_position+no_samp_period;
	}
		
	
	return mconst;
	
}

public static double[][] mod_const_ts(int ts_stream[], int L,int levels){
	double xi = 0;
	double yi = 0;
	double mconst[][] =new double[((int) ( (double) L/((double) 2*levels)))][2];
	int current_position=0;


	for(int n=0;n<=L-2*levels;n=n+2*levels){
		xi=0;
		yi=0;
		for(int m=0;m<2*levels;m=m+2){
			if(ts_stream[n+m]==0){      
				xi=xi+A*Math.pow(2, m/2);

			}else{
				xi=xi-A*Math.pow(2, m/2);
			}     
			if(ts_stream[n+m+1]==0){
				yi=yi+A*Math.pow(2, m/2);

			}else{
				yi=yi-A*Math.pow(2, m/2);
			}


		}


		mconst[current_position][0]=1*xi;
		mconst[current_position][1]=1*yi;
		current_position++;
	}

	return mconst;	
}

public int[] demod_const(Complex[] H, int levels){
	double th_x;
	double th_y;
	double i_x;
	double i_y;
	int mdem[]=new int[H.length*2*levels]; 
	int current_position=0;
	
	for(int m=0;m<H.length;m++){
		int sym[]=new int[2*levels];
		int sym_pos=0;
		th_x=0;th_y=0;
		i_x=0;i_y=0;

		for(int n=0;n<levels;n++){
			if (H[m].im() > th_y ){ //compare with border of decision region
				sym[sym_pos]=0;
				i_y=1;
			}else{
				sym[sym_pos]=1;
				i_y=-1;
			}
			sym_pos++;

			if(H[m].re() > th_x){
				sym[sym_pos]=0;
				i_x=1;
			}else{
				sym[sym_pos]=1;
				i_x=-1;
			}
			sym_pos++;
			th_y = th_y + A*i_y*Math.pow(2, levels-(n+1));
			th_x = th_x + A*i_x*Math.pow(2, levels-(n+1));
		}

		
		for(int k=0;k<sym_pos;k++){
			mdem[current_position+k]=sym[sym_pos-k-1];
		}
		current_position = current_position + sym_pos;
		
	}
	return mdem;
}

@SuppressLint("NewApi")
public  double[] MQAMmod(int f, int[] bits){
	int L;
	if(bits.length%(2*levels) != 0){
		L=bits.length+2*levels-(bits.length%(2*levels));}
	else{
		L=bits.length;
	}
	int bit_stream[] = new int[L];
	bit_stream = Arrays.copyOfRange(bits, 0, bit_stream.length);
	double[] signal = new double[L/(2*levels)*no_samp_period];
	double[][] mconst = mod_const(bit_stream, L, levels);
	
	Complex[] tx_const = new Complex[mconst.length];
	for(int k=0;k<mconst.length;k++){
		tx_const[k]=new Complex(mconst[k][0],mconst[k][1]);
	}
	save_c_to_file("tx_const.txt",tx_const,tx_const.length);
	
	for(int i=0;i<L/(2*levels);i++){
		for(int ii=i*no_samp_period;ii<no_samp_period*(i+1);ii++){
			signal[ii]=window[ii-i*no_samp_period]*mconst[ii][0]*cosf1[ii-i*no_samp_period]-window[ii-i*no_samp_period]*mconst[ii][1]*sinf1[ii-i*no_samp_period];
			
		}
	}

	return signal;

}



public double[] modulateQAM_ts(int length,int f,int levels){
	SimpleInputFile in = new SimpleInputFile();
	
    in.open("ts_test.txt"); 
    length = in.readInt();
    ts_length=length;
    //add_output_text_line("ts_length="+ts_length);
	final int [] ts = new int[length*2*levels];
	
	
	ts_stream=new int[length*2*levels];
	   // Read file from sdcard
    for(int i=0; i<ts.length; i++){
           ts[i]=in.readInt(); 
           ts_stream[i] = ts[i];
    };
   //add_output_text_line("ts(0,1)="+ts[0]+""+ts[1]);
    in.close();
	final double[] mod_ts = MQAMmod(f,ts);
	ts_mod_const = mod_const_ts(ts,ts.length,levels);
	
	return mod_ts;
}
	

@SuppressLint("NewApi")
public int[] MQAMreceiver(int f,int n_sym,double[] r){
	
	double Vx[]=new double[r.length];
	double Vy[]=new double[r.length];
	int a=0;
	for(int k=0;k<r.length;k++){
		Vx[k]=r[k]*cosf1[k%no_samp_period];
		Vy[k]=-r[k]*sinf1[k%no_samp_period];
	}
	
//	double[] cosf=initCosine(f1,mysampleRate,r.length);
//	double[] sinf=initSinusoid(f1,mysampleRate,r.length);
//	for(int k=0;k<r.length;k++){
//		Vx[k]=r[k]*cosf[k];
//		Vy[k]=-r[k]*sinf[k];
//	}
//	
	//save_d_to_file("Vx.txt",Vx,r.length);
	//save_d_to_file("Vy.txt",Vy,r.length);
	
	
	double Hx[]  = LPfir(Vx);
	double Hy[] =  LPfir(Vy);
	
	int margin = 10;
	int block_length = (margin+ts_length)*no_samp_period;
	
	
	//save_d_to_file("Hx.txt",Hx,Hx.length);
	//save_d_to_file("Hy.txt",Hy,Hy.length);

	//save_to_file("Hy.txt",Arrays.copyOfRange(Hy,0,block_length),block_length);
//	double[] ts_real=new double[ts_mod_const.length];
//	double[] ts_imag=new double[ts_mod_const.length];
//	for(int k=0;k<ts_mod_const.length;k++){
//		ts_real[k]=ts_mod_const[k][0];
//		ts_imag[k]=ts_mod_const[k][1];
//	}
//	save_to_file("ts_real.txt",Arrays.copyOfRange(ts_real,0,ts_mod_const.length),ts_mod_const.length);
//	save_to_file("ts_imag.txt",Arrays.copyOfRange(ts_imag,0,ts_mod_const.length),ts_mod_const.length);
	
	
	int n_samp = synchronize(Arrays.copyOfRange(Hx,0,block_length),Arrays.copyOfRange(Hy,0,block_length),
							 ts_mod_const,no_samp_period);
	
	double Hxs[] = new double[Hx.length];
	double Hys[] = new double[Hy.length];
	int current_position = 0;
	for(int k=n_samp;k<Hx.length;k=k+no_samp_period){
		Hxs[current_position] = Hx[k];
		Hys[current_position] = Hy[k];
		current_position++;
	}
	//save_d_to_file("mconstJavay.txt",Hys,current_position);
	//save_d_to_file("mconstJavax.txt",Hxs,current_position);
	// Phase estimation
	
	Complex mconst[] = phase_estimation(Arrays.copyOfRange(Hxs, 0, current_position),Arrays.copyOfRange(Hys, 0, current_position),ts_mod_const,current_position);
	
	//save_c_to_file("mconst.txt",mconst,mconst.length);
	Complex[] demconst = new Complex[mconst.length];
	double theta = 0;
	
	double Ts = (double) no_samp_period / (double) mysampleRate;
	int batch_length = (int) Math.floor(0.1/Ts);
    int[] decision = new int[mconst.length*2*levels];
	current_position = 0;
	//add_output_text_line("b_l="+batch_length);
	
	for(int k = 0 ; k < (int) Math.floor((double) mconst.length/(double) batch_length); k++){
		Complex[] mconst_phi =new Complex[batch_length];
		Complex complex_exp =new Complex(Math.cos(-phihat), Math.sin(-phihat));
		for(int q=(k*batch_length);q<(k+1)*batch_length;q++){
			mconst_phi[q-k*batch_length]=mconst[q];
			mconst_phi[q-k*batch_length]=mconst_phi[q-k*batch_length].times(complex_exp);
//		 Complex aux = mconst_phi[q-k*batch_length]; 
//			mconst_phi[q-k*batch_length]=new Complex(aux.re()+aux.im()*Math.tan(gama),aux.im()/Math.cos(gama) );
				
		}
		int decision_aux[] = demod_const(mconst_phi,levels);
		System.arraycopy(mconst_phi, 0, demconst, k*batch_length , batch_length);
		// copies an array from the specified source array
		
		System.arraycopy(decision_aux, 0, decision, current_position , decision_aux.length);
		
		current_position = current_position + decision_aux.length;
		theta = offset_estimation(mconst_phi,decision_aux);
		phihat = phihat + theta;
		
		
	}

	
	int k = (int) Math.floor((double) mconst.length/ (double) batch_length);
	Complex[] mconst_phi =new Complex[mconst.length-(k)*batch_length];
	
	Complex complex_exp =new Complex(Math.cos(-theta),Math.sin(-theta));
	for(int q=(k)*batch_length; q < mconst.length ;q++){
		mconst_phi[q-(k)*batch_length] = mconst[q];
		mconst_phi[q-(k)*batch_length]=mconst_phi[q-(k)*batch_length].times(complex_exp);
		demconst[q] = new Complex(0,0);
	}
	int decision_aux[] = demod_const(mconst_phi,levels);
	// copies an array from the specified source array
	System.arraycopy(decision_aux, 0, decision, current_position, decision_aux.length);
	//current_position = current_position + decision_aux.length;
	save_c_to_file("demconst.txt",demconst,demconst.length);
	
	//	int decision[] = demod_const(mconst,levels);
	return Arrays.copyOfRange(decision, ts_length*2*levels, decision.length);
}

@SuppressLint("NewApi")
public double[] LPfir(double[] input){
	SimpleInputFile in = new SimpleInputFile();
    in.open("coeffs8.txt");
    int length = in.readInt();
	final double [] coeffs = new double[length];
	   // Read file from sdcard
    for(int i=0; i<coeffs.length; i++){
           coeffs[i]=in.readDouble(); 
    };
    in.close();
	double ext_input[]=new double[input.length+length];
	ext_input = Arrays.copyOfRange(input, 0, ext_input.length);
    FIR filter =new FIR(coeffs);
    double[] out = new double[input.length+length];
    for(int k=0;k<input.length+length-1;k++){
    	out[k] = filter.getOutputSample(ext_input[k]);
    }
    
	return out;
	
}

public int synchronize(double Hx[],double Hy[],double[][] ts_const,int Q){
	int n_samp=0;
	Complex mconst[] = new Complex[Hx.length];
	int current = 0;
	for(int k=0;k<Hx.length;k++){
		mconst[k] = new Complex(Hx[k],Hy[k]);
	}
	Complex tsconst[] = new Complex[ts_const.length*Q];

	for(int k=0;k<Q*ts_const.length;k++){
		if(k%Q==0) {tsconst[k] = new Complex(ts_const[current][0],ts_const[current][1]); current++; 
		}else{
			tsconst[k] = new Complex(0,0);
		}
	}
	
	Complex aux = new Complex(0,0);
	double[] c= new double[mconst.length-tsconst.length+2];
	double maxc=0;
	
	for(int i = 0; i < mconst.length-tsconst.length;i++){
		c[i]=0;
		aux = new Complex(0,0);
		for(int ii=0;ii<tsconst.length;ii++){
			aux = aux.plus(mconst[ii+i].times(tsconst[ii].conjugate()));
			
		}
		c[i]=aux.abs();
	}
	
	for(int i=0;i<c.length;i++){
		if(c[i]>maxc){
			n_samp=i;
			maxc=c[i];
		}
	}

	return n_samp-1;

}

public double[] create_window(int mode){ //MODE 0->RECT MODE 1->WINDOW.TXT
	double[] window = new double[no_samp_period];
	if(mode==0){ 
		for(int k=0;k<window.length;k++){
			window[k]=1;
		}
		return window;
	}else{
		if(mode==1){
			SimpleInputFile in = new SimpleInputFile();
			in.open("window8.txt");
			int length = in.readInt();
			if(length==no_samp_period){
				// Read file from sd card
				for(int i=0; i<window.length; i++){
					window[i]=in.readDouble(); 
				}
				in.close();
				return window;
			}else{ create_window(0);}
		}
	}
	return window;
}

public Complex[] phase_estimation(double[] Hx,double[] Hy, double[][] mconst_ts,int length){
	
//	// Save input variables to file for debugging purposes
//	save_to_file("Hx.txt", Hx , length);
//	save_to_file("Hy.txt", Hy,  length);
//	double[] ts_real = new double [mconst_ts.length];
//	double[] ts_imag = new double [mconst_ts.length];
//	
//	// Extract real and imaginary parts of mconst_ts
//	for (int i=0;i<mconst_ts.length;i++){
//		ts_real[i] = mconst_ts[i][0]; 
//		ts_imag[i] = mconst_ts[i][1];
//	}
//	
//	save_to_file("ts_real.txt",ts_real,ts_real.length);
//	save_to_file("ts_imag.txt", ts_imag,ts_imag.length);
	
	// Initialize variables
	double ref = 0;
	double arg_sum = 0;
	Complex mconst[] = new Complex[mconst_ts.length];
	Complex rx[]=new Complex[length];

	for(int k=0;k<mconst_ts.length;k++){
		mconst[k] = new Complex(mconst_ts[k][0],mconst_ts[k][1]);
	}
	
	for(int k=0;k<length;k++){		
		rx[k] = new Complex(Hx[k],Hy[k]);
	}
	
	
	save_c_to_file("mconst_before.txt",rx,length);
//	double aux_re;
//	double aux_im;
//	double ref_re = 0;
//	double ref_im = 0;
	for (int i=0;i<mconst_ts.length;i++){
		Complex x = rx[i].times(mconst[i].conjugate());
		double argx = x.phase();
		arg_sum=arg_sum+argx;
		double aux = (rx[i].abs())/(mconst[i].abs());
		ref = ref+aux;
//		aux_re = Math.abs(rx[i].re())/Math.abs(mconst[i].re());
//		aux_im = Math.abs(rx[i].im())/Math.abs(mconst[i].im());
//		ref_re = ref_re + aux_re;
//		ref_im = ref_im + aux_im;
	}

	ref = ref / (double) mconst_ts.length;
	//add_output_text_line("ref="+ref);
	
	phihat = arg_sum /(double) mconst_ts.length;
	//add_output_text_line("phihat="+phihat);
	
//	ref_re = ref_re / (double) mconst_ts.length;
//	ref_im = ref_im / (double) mconst_ts.length;
	
//	Complex complex_exp =new Complex(Math.cos(-phihat),Math.sin(-phihat));
	Complex complex_exp =new Complex(1,0);
	Complex aux = new Complex(ref,0);
//	Complex mconst_sym[] = new Complex[Hx.length-mconst_ts.length];
//	
//	for(int i =0;i<mconst_sym.length;i++){
//		mconst_sym[i]=new Complex(0,0);
//	}
//	for(int k=mconst_ts.length;k<Hx.length;k++){
//		
//		mconst_sym[k-mconst_ts.length] = rx[k].times(complex_exp);
//		mconst_sym[k-mconst_ts.length] = mconst_sym[k-mconst_ts.length].divides(aux);
//		
//		//mconst_sym[k-mconst_ts.length] = new Complex(mconst_sym[k-mconst_ts.length].re()/ref_re,mconst_sym[k-mconst_ts.length].im()/ref_im);
//	}
	
	Complex mconst_sym[] = new Complex[length];
	
	for(int i =0;i<mconst_sym.length;i++){
		mconst_sym[i]=new Complex(0,0);
	}
	for(int k=0;k<length;k++){
		
		mconst_sym[k] = rx[k].times(complex_exp);
		mconst_sym[k] = mconst_sym[k].divides(aux);
		
		//mconst_sym[k-mconst_ts.length] = new Complex(mconst_sym[k-mconst_ts.length].re()/ref_re,mconst_sym[k-mconst_ts.length].im()/ref_im);
	}
	
//	Complex rx_ts[] = new Complex[mconst_ts.length];
	
	
//	for(int k=0;k<mconst_ts.length;k++){
//		 rx_ts[k] = rx[k].times(complex_exp);
//		//mconst_sym[k-mconst_ts.length] = mconst_sym[k-mconst_ts.length].divides(aux);
//		
//		rx_ts[k] = new Complex(rx_ts[k].re() / ref_re , rx_ts[k].im()/ref_im);
//	}
//	
//	gama = skew_estimation(rx_ts,mconst);
//	add_output_text_line("gama="+gama);
	// Initialize real and imag
	
//	double[] real2 = new double [mconst_sym.length];
//	double[] imag2 = new double [mconst_sym.length];
//	// Extract real and imaginary parts of the complex values
//	for (int i=0;i<mconst_sym.length;i++){
//		real2[i] = mconst_sym[i].re();
//		imag2[i] = mconst_sym[i].im();
//	}
	// Save output variables to file for debugging purposes
//	save_to_file("out_real.txt", real2,real2.length);
//	save_to_file("out_imag.txt", imag2,imag2.length);
	
	return mconst_sym;
	
}

// Equalizer
public double[] EQ(double[] input){
	SimpleInputFile in = new SimpleInputFile();
    in.open("eqcoeffs8.txt");
    
	final double [] a = new double[3];
	final double [] b = new double[3];
	   // Read file from sdcard
    for(int i=0; i<b.length; i++){
           b[i]=in.readDouble(); 
    };
    for(int i=0; i<a.length; i++){
        a[i]=in.readDouble(); 
 };
    in.close();
	IIR filter =new IIR(b,a);
    double[] out = filter.getOutput(input);
   
    
	return out;
	
}

public double offset_estimation(Complex[] mconst,int[] bit_stream){
	Complex[] demconst = new Complex[bit_stream.length/(2*levels)];
	double xi;
	double yi;
	int current_position = 0;
	for(int n=0;n<=bit_stream.length-2*levels;n=n+2*levels){
		xi=0;
		yi=0;
		for(int m=0;m<2*levels;m=m+2){
			if(bit_stream[n+m]==0){      
				xi=xi+A*Math.pow(2, m/2);

			}else{
				xi=xi-A*Math.pow(2, m/2);
			}     
			if(bit_stream[n+m+1]==0){
				yi=yi+A*Math.pow(2, m/2);

			}else{
				yi=yi-A*Math.pow(2, m/2);
			}


		}
		demconst[current_position]= new Complex(xi,yi); current_position++;
}
	//add_output_text_line("current="+current_position);
	double arg_sum = 0;
	for (int i=0;i<current_position;i++){
		Complex x = mconst[i].times(demconst[i].conjugate());
		double argx = x.phase();
		arg_sum=arg_sum+argx;
		
	}
	arg_sum =  arg_sum / (double) current_position;
	
	return arg_sum;
	
}	

}


//
//public static final byte[] double2Byte(double[] inData) {
//    int j=0;
//    int length=inData.length;
//    byte[] outData=new byte[length*8];
//    for (int i=0;i<length;i++) {
//      long data=Double.doubleToLongBits(inData[i]);
//      outData[j++]=(byte)(data>>>56);
//      outData[j++]=(byte)(data>>>48);
//      outData[j++]=(byte)(data>>>40);
//      outData[j++]=(byte)(data>>>32);
//      outData[j++]=(byte)(data>>>24);
//      outData[j++]=(byte)(data>>>16);
//      outData[j++]=(byte)(data>>>8);
//      outData[j++]=(byte)(data>>>0);
//    }
//    return outData;
//  }
//
//public double skew_estimation(Complex[] r, Complex[] ts){
//	
//	double total = 0;
//
//	for(int k = 0; k<ts.length;k++){
//		if(r[k].im()/ts[k].im()<1){
//			double aux = Math.acos(r[k].im()/ts[k].im());
//			total++;
//			gama = gama + aux;
//		}
//
//
//
//
//	}
//	gama=gama/total;
//	return gama;
//
//}
// 
//
//
//




