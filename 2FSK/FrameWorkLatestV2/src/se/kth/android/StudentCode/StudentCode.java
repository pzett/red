/* Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
* This software is provided  抋s is�. It is free to use for non-commercial purposes.
* For commercial purposes please contact Peter H鋘del (peter.handel@ee.kth.se)
* for a license. For non-commercial use, we appreciate citations of our work,
* please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
* for how information on how to cite. */ 

package se.kth.android.StudentCode;

import java.io.BufferedReader;

import java.util.ArrayList;
//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Date;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.Object;
import android.app.Activity;

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



//import se.kth.android.FrameWork.FrameWork;
import se.kth.android.FrameWork.StudentCodeBase;


import android.annotation.SuppressLint;
import android.content.Context;
//import android.graphics.Bitmap;
import android.graphics.Canvas;
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
    final Complex input[] = {new Complex(3,2) ,new Complex(1,2), new Complex(3,8), new Complex(4,3)};
    Complex i;
    final double inputxcorr[]={1,5.6,2.4,9.69, 15.7};
    final double inputycorr[]={1,2};
    
     final static int no_samp_period = 30;
    final static int f1=mysampleRate/4;
    final static int f2=mysampleRate/6;
    final static int f3=mysampleRate/7;
    final static int f4=mysampleRate/8;
    final static int ts_f1=mysampleRate/20;
    final static int ts_f2=mysampleRate/15;
    
    final static double[] cosf1 =initCosine(f1, mysampleRate,no_samp_period);
    final static double[] cosf2 =initCosine(f2, mysampleRate,no_samp_period);
    final static double[] cosf3 =initCosine(f3, mysampleRate,no_samp_period);
    final static double[] cosf4 =initCosine(f4, mysampleRate,no_samp_period);
    
    
       
    
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
    private static int ts_length = 100;
    private static int gb_length = 30;
    private static double[] ts_mod;
    private static int side=-1;
    
    // Variables for function: int[] data_buffer_bits() and void retrieveData(int[] received)
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
	int[] sizeofFile; //= new int [128];
	int[] titleofFile;  //= new int [16];
	final int GETDATA = 0; 
	final int RECEIVED = 1;
	final int SEND = 2;
	final int END = 2;
	final int WRITE = 2;
	final int FIRST = 0;
	final int SECOND = 1;
    
	final int length_titleFile = 1024;
	final int length_sizeFile  = 512;
	AudioTrack atp; 
 
	
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
           
           int length_rxb =no_samp_period*2000*10;
           rx_buffer = new short[length_rxb];
          
                     
           ts_mod = modulate_ts(ts_length,ts_f1,ts_f2);
           
           atp = new AudioTrack(AudioManager.STREAM_MUSIC,
                   mysampleRate, AudioFormat.CHANNEL_OUT_MONO,
                   AudioFormat.ENCODING_PCM_16BIT, bufferInt.length,
                   AudioTrack.MODE_STREAM);
          
          
          add_output_text_line("f1= "+f1+" f2= "+f2+" k= "+no_samp_period);
         

    }

    // This is called when the user presses start in the menu, reinitialize any data if needed
    public void start()
    {    
    	trigger=0;
    	
    	if(side==0){
    		browseForFile();
    		
    	}
    	//set_output_text("d_filename ="+d_filename);
           // Start audio recording
    	 //int corr = maxXcorr(inputxcorr,inputycorr); 
    	//add_output_text_line("index="+corr);
    	
    	
    }
     
    // This is called when the user presses stop in the menu, do any post processing here
    public void stop()      
    {
          trigger=-1;
          rx_ind=0;
          clear_output_text();
          set_output_text("Stopped.");
          side=-1;
          
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
//    FFT x,y,z;
   
    // Fill in the process function that will be called according to interval above
    @SuppressLint("NewApi")
	public void process()
    {  
    	//Complex[] y =   fft(input);
    	
    	//z=FFT.cconvolve(x, y)   ;
    	
    	  //Complex a =new Complex(2,3);
          //Complex b =new Complex(1,6);
    	
        if(d_filename != null) state=GETDATA; //file has been picked
    	
    	switch(state){
    	
    	// Convert file to be sent into a binary stream stored in bit_buffer
    	case GETDATA:
    		bit_buffer = data_buffer_bits();
    	    break;
    	    
    	// Send data stored in bit_buffer
    	case SEND:  
    		send_data();
    		
        // Receiver part
    	case RECEIVED:
    	if(trigger==2){
    		add_output_text_line("stopped listening, decoding");
        	  //useSensors =  SOUND_OUT;
        	  int block_length=no_samp_period*(gb_length+ts_length+40); //block to do autocorrelation
        	  double[] rx_bufferdouble = new double[rx_buffer.length]; //buffer of doubles
        	  add_output_text_line("buffer length="+rx_buffer.length+"rx_ind = "+rx_ind);
        	  for (int j=0;j<rx_ind;j++) {
        	      rx_bufferdouble[j] = (double)rx_buffer[j]; //convert received samples to doubles.
        	  }
        	  
        	  int index = maxXcorr(Arrays.copyOfRange(rx_bufferdouble, 1, block_length),ts_mod); //find where training sequence begins
        	  
        	  //send received data to goertzel algorithm, copy only data part
        	  int decision[]=goertzel(f1,f2,no_samp_period, Arrays.copyOfRange(rx_bufferdouble,index+no_samp_period*ts_length,rx_buffer.length));
        	  //save decision to file
        	  save_to_file("decision.txt", decision,decision.length);
        	  
        	  //compare(decision);
        	  
        	  // Convert binary stream back into a file
        	  retrieveData(decision);
        	  //clear_output_text();
        	  
        	  //readFile("received.txt");
        	  add_output_text_line("stopped listening");
          	  trigger=-1;
        	  state=-1;
        	  d_filename = null;
        	  //stop();
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
    			rx_buffer=send_to_buffer(rx_buffer,length-i-1,samples);
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
		d_filename=filename;
		//add_output_text_line("you chose "+d_filename+" for sending");
	}
   
    public void stringFromUser(String user_input)
    {
        
         SimpleOutputFile out = new SimpleOutputFile();
        //Call the function to be tested 
         out.open("message.txt");
         out.writeString(user_input);
    	// Write file on sdcard 
    	  d_filename="message.txt";
//    	       trigger=0;  
//    	       side=0;
//    	       init(0);
    	    out.close(); 
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
	 
	 double k1=0.5+ n*f1/fs;
	 double k2=0.5+ n*f2/fs;
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
	 
	 int[] decision= new int[aux];
	 for(int l=0;l<aux;l++){
		 if(mag1[l]>mag2[l]){
			 decision[l]=1;
		 }else{
			 decision[l]=0;
		 }
	 }
 	 return decision;
	 
 }
 
 public static int maxXcorr(double[] x,double[] y){
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
	 
	 return index;
 }
 
 public static double[] FSK_mod(int f1,int f2, int[] r){
 	double[] signal = new double[no_samp_period*r.length];
 	
 for(int i=0;i<r.length;i++){
	 if(r[i]==1){
		 for(int ii=i*no_samp_period;ii<no_samp_period*(i+1)-1;ii++){
			 signal[ii]=cosf1[ii-i*no_samp_period];
			  }
	 }
	 else{
		 for(int ii=i*no_samp_period;ii<no_samp_period*(i+1)-1;ii++){
			 signal[ii]= cosf2[ii-i*no_samp_period];
		 }
	 }
	 
 }
return signal;
}
 
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
 
 public static double[] initCosine(int f, int fs,int N){
	 double cosf[]=new double[N];
	 for(int k=0;k<N;k++){
		 cosf[k] = Math.cos(2 * Math.PI * f * k / (fs));
	 }
	 return cosf;
 }
 
void send_data(){
	int Nb = 5000;
//	int[] bit_stream = new int[Nb];
	int[] guard_stream = new int[gb_length];
	int current_position=0;
	
	//int[] size_data_signal = new int [100];
//	for(int i = 0;i<Nb;i++){
//		bit_stream[i]=Math.round((float) Math.random());
//		}
//	bit_stream = load_from_file("data_test.txt",Nb);
//	save_to_file("data.txt",bit_stream,Nb);
	
	double[] guard_signal = FSK_mod(f1,f2,guard_stream);
	double[] data_signal = FSK_mod(f1,f2,bit_buffer);
	double[] size_data_signal = FSK_mod(f1,f2,sizeofFile);
	double[] title_data_signal = FSK_mod(f1,f2,titleofFile);
	// Size of total signal to be transmitted
	double[] tx_signal =new double[guard_signal.length+data_signal.length+ts_mod.length+bufferInt.length+title_data_signal.length+size_data_signal.length];
	
	for(int i=0;i<guard_signal.length;i++){
		tx_signal[current_position]=guard_signal[i];
		current_position++;
	}
	for(int i=0; i<ts_mod.length; i++){
		tx_signal[current_position]=ts_mod[i];
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
//	for(int i=0;i<bufferInt.length-current_position%bufferInt.length+1;i++){
//		tx_signal[current_position+i]=0;
//	}
//	
	final AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC,
            mysampleRate, AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT, bufferInt.length,
            AudioTrack.MODE_STREAM);
	
	
    for (int i = 0; i < tx_signal.length; i++) {
        play(tx_signal[i], audioTrack);
    }
    add_output_text_line("done with buffering of transmission");
    state=-1;
    //add_output_text_line("tx_signal[1]"+tx_signal);
   
}

public static void play(double in, AudioTrack at) {

    // clip if outside [-1, +1]
    if (in < -1.0) in = -1.0;
    if (in > +1.0) in = +1.0;

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

public static short[] send_to_buffer(short[] rx_buffer, int length, short[] samples) {
	//copy buffer
	for (int i=0;i<length;i++){
		rx_buffer[i+rx_ind]=samples[i];
	}
	if(rx_ind+2*length<=rx_buffer.length){
	rx_ind=rx_ind+length;
	//add_output_text_line("rx_ind"+rx_ind);
	}else{
		//add_output_text_line("reached the end of buffer");
		trigger=2;
		
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

public void save_to_file(String filename,int[] data,int length){
	SimpleOutputFile out = new SimpleOutputFile();
	out.open(filename);
	out.writeInt(length);
	for(int i=0; i<data.length; i++){
      out.writeInt(data[i]);
	}
	out.close();
	
	
}

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

public void compare(int decision[]){
	int[] length_vec=load_from_file("data_test.txt",0);
	float length = length_vec[0];
	add_output_text_line("length of tx_seq"+length);
	int tx_seq[];
	tx_seq=load_from_file("data_test.txt",1);
	float e = 0;
	for (int a = 0; a < length; a++) {

        if (tx_seq[a] == decision[a]) {
            e=e;
            } else {
            e++;
        }
	}
	double BER =e/length;
	add_output_text_line("BER="+BER);
	
}

public int[] data_buffer_bits(){
	   if (init_done && (!file_loaded) && (!(d_filename==null))) {
			
			the_file_contents=read_data_from_file(d_filename); // Read file from plain file of samples in form of shorts
			
			// Store length of file in int[] of bits
			String sizeofFile_s = Integer.toBinaryString(the_file_contents.length);
			//add_output_text_line("size_b="+sizeofFile_s);
			byte[] sizeofFile_b = sizeofFile_s.getBytes();
			//sizeofFile = new int[8*sizeofFile_b.length];
			sizeofFile = new int[length_sizeFile];
			//sizeofFile = new int[128];
			for (int k=0;k<sizeofFile_b.length;k++) {				
     		    for (int k1=0; k1<8; k1++){
			    // Turn each byte into its corresponding bits
				sizeofFile [8*k+k1]=(sizeofFile_b[k] >> (7-k1) & 1);
				}
			}
			
			// Store name and extension, d_filename, in int[] of bits
			byte[] titleofFile_b = (d_filename.getBytes());	
			//titleofFile = new int[8*titleofFile_b.length];
			titleofFile = new int[length_titleFile];
			for (int k=0;k<titleofFile_b.length;k++) {				
     		    for (int k1=0; k1<8; k1++){
			    // Turn each byte into its corresponding bits
				titleofFile [8*k+k1]=(titleofFile_b[k] >> (7-k1) & 1);
				}
			}
			add_output_text_line("size of chosen file="+sizeofFile_s+"(length="+the_file_contents.length+")");
			add_output_text_line("title of chosen file="+d_filename);
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

public void retrieveData(int[] received){
	   //receivedBits = new int [numberBits];
	   //the_file_contents=read_data_from_file(d_filename);
	   //int[] data_test = received;
	   //double[] data_temp = null;
	   //int m;
	   byte[] data_buffer_received = new byte[received.length/8];
	   int receivedBitstemp[] = new int [8];
	   
	   //data_buffer_bits = new int[numberBits/8];
	   state_two=FIRST;
	   //data_buffer = new byte [the_file_contents.length];
	   //Convert bits to bytes, note: LITTLE_ENDIAN
	   switch(state_two){
	   case FIRST:
	   for (int k=0;k<received.length/8;k++){
	//	   m=7;
		   //data_buffer[k] = (byte) ()
		   StringBuilder concatenated = new StringBuilder(8);
		   for (int k1=0;k1<8;k1++){
			   receivedBitstemp[k1]=received[8*k+k1];
			   concatenated.append(receivedBitstemp[k1]);
			//   data_temp[k]=data_temp[k]+(receivedBitstemp[k+k1]*Math.pow(2, m));
			//		   m=m-1;
		   }
		   String data_concatenated = concatenated.toString();
		 //  data_buffer_received[k] = (byte) data_temp[k];

		     
		   //Integer.valueOf(concatenated.toString());
		   
		  // int receivedBitstemp_test = receivedBitstemp[0] receivedBitstemp[1] receivedBitstemp[2] ;
		
		   data_buffer_received[k]= (byte) Integer.parseInt(data_concatenated,2);
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
	    byte[] data_buffer_received_size = new byte[length_sizeFile/8];
	    
	    int counter=length_titleFile/8;
	    //for (int k=64;k<80;k++){
	    	while(data_buffer_received[counter]!=0){
		    data_buffer_received_size[counter-length_titleFile/8]=data_buffer_received[counter];
		    counter++;
		    //b1 = data_buffer_received_size[k];
		    //b1.intValue();
		    }
	    //}
	    String data_buffer_received_size_c="";
	    for (int k=length_titleFile/8;k<counter;k++){
		    data_buffer_received_size_c += (char) data_buffer_received_size[k-length_titleFile/8];
		    }
	    
	    int size_i= Integer.parseInt(data_buffer_received_size_c,2);
	    add_output_text_line("size of received="+size_i);
	    // Get data, remove size and title of file from the received buffer
	    //byte[] data_buffer_received = null;
	   
	    
	    byte[] data_buffer_received_n = new byte[(received.length/8)-(length_titleFile+length_sizeFile)/8];
	    for (int k=(length_titleFile+length_sizeFile)/8;k<(length_titleFile+length_sizeFile)/8+size_i;k++){ //received.length/8
		  data_buffer_received_n[k-(length_titleFile+length_sizeFile)/8]=data_buffer_received[k];
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
	    for(int l=counter+1;l<data_buffer_received_title.length;l++){
	    	data_buffer_received_ext += (char) data_buffer_received_title[l];
	    }
	    /*
	    String data_buffer_received_title_n = "";
	    for (int i=0;i<data_buffer_received_title.length;i++){
	      data_buffer_received_title_n += new String(Byte.toString(data_buffer_received_title[i]));
	    }
	    */
	    
	    
	    //String sizeofFile_s = Integer.(the_file_contents.length);
	    // Create file
		FileOutputStream outFile;		
		//d_filename="received";
		File out = new File(Environment.getExternalStorageDirectory().getPath());
		add_output_text_line("title of received file="+data_buffer_received_title_n);
		// The file name to be written and stored
		String filename_title = new String(out+"/"+data_buffer_received_title_n+"."+data_buffer_received_ext);
		
		try {
			File file = new File(filename_title);
			long fileLength = file.length();
			//dataBuffer = new byte[(int) fileLength];
			//dataFile = new FileInputStream(file);
			outFile = new FileOutputStream(file);
			outFile.write(data_buffer_received_n); // Write whole buffer
			outFile.close();
			//state=2;
		} catch (IOException e) {
			e.printStackTrace();
		};
		
	   }
}



public void readFile(String received)
{
	SimpleInputFile in = new SimpleInputFile();
	in.open(received);
	String result = in.readString();
	while(result != null){
		add_output_text_line("line="+result);
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
public static double[] FSK_mod4(int f1,int f2, int f3, int f4, int[] r){
 	double[] signal = new double[no_samp_period*r.length];
 	
    int current = 0;
    int[] r_two = new int [2];
    
 	for(int i=0;i<r.length;i=i+2){
 		StringBuilder concatenated = new StringBuilder(2);
 		for(int k1=0;k1<2;k1++){
 			r_two[k1]=r[i+k1];
 			current++;
 			concatenated.append(r_two[k1]);
 		}
	 	    
	 	    String data_concatenated = concatenated.toString();
 		   int a=i/2;
	 	   if(data_concatenated=="00"){
				 for(int ii=a*no_samp_period;ii<no_samp_period*(a+1)-1;ii++){
					 signal[ii]=cosf1[ii-a*no_samp_period];
					  }
			 }
			 else if(data_concatenated=="01"){
				 for(int ii=a*no_samp_period;ii<no_samp_period*(a+1)-1;ii++){
					 signal[ii]= cosf2[ii-a*no_samp_period];
				 }
			 }
			 else if(data_concatenated=="11"){
				 for(int ii=a*no_samp_period;ii<no_samp_period*(a+1)-1;ii++){
					 signal[ii]= cosf3[ii-a*no_samp_period];
				 }
			 }
			 else if(data_concatenated=="10"){
				 for(int ii=a*no_samp_period;ii<no_samp_period*(a+1)-1;ii++){
					 signal[ii]= cosf4[ii-a*no_samp_period];
				 }
			 }
 		
 	}

return signal;
}


}