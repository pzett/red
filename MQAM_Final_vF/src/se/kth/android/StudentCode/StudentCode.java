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
import android.graphics.Color;
import android.graphics.Paint;
//import android.graphics.Color;
//import android.graphics.Paint;
//import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Paint.Style;
import android.graphics.drawable.Drawable;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.net.wifi.ScanResult;
import android.os.Environment;
import android.os.Handler;
import android.widget.ImageView;


public class StudentCode extends StudentCodeBase {
	 
	boolean init_done=false;
	boolean file_loaded=false;


	short buffer[];

	private static final int mysampleRate = 44100;

	final static int no_samp_period = 8;
	final static int f1=mysampleRate/4;


	int ts_stream[];
	final static double[] cosf1 =initCosine(f1, mysampleRate,no_samp_period);
	final static double[] sinf1 =initSinusoid(f1, mysampleRate,no_samp_period);
	final static int levels = 3;
	final static int A = 1;

	double phihat;
	// Initialize cosines with specified frequency used for training sequence transmission
    
    
    private static final double MAX_16_BIT = Short.MAX_VALUE; 
    private static final int SAMPLE_BUFFER_SIZE = 4096;
    private static byte[] bufferInt;         // our internal buffer
    private static int bufferSize = 0;    // number of samples currently in internal buffer
    private static int bufferLength = 4096; 
    private static final int BYTES_PER_SAMPLE = 2;                // 16-bit audio
        
    public static int trigger = 0; //0 -> listening and waiting 1 -> listening and received 2 -> done listening -1 ->processed
    private static short[] rx_buffer;
    private static int rx_ind=0;

    public  int gb_length=0;
    public  int ts_length=0;
    private static double[] ts_mod;
    private static double[][] ts_mod_const;
    private static double[] window;
    
    public int side=-1;
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
    public int state=-1;
	int state_two = 0;
	int[] sizeofFile; 
	int[] titleofFile;
	int[] checksumofFile;
	long C_sum_tx;
	long C_sum_rx;
	
	final int sizeofFileLimit= 50000;
	
	// Variables used in the switch cases
	final int GETDATA = 0; 
	public final int RECEIVED = 1;
	final int SEND = 2;
	final int END = 2;
	final int WRITE = 2;
	final int FIRST = 0;
	final int SECOND = 1;
    
	// Variable keeping in track of any errors that might occur
    public boolean error = false;
    
    // Needs to be divisible by 8 and a number that depends on variable levels (currently 6) 
	final int length_titleFile = 768;
	final int length_sizeFile  = 768;
	final int length_checksum = 768;
	String rx_filename;
 
    // This is called before any other functions are initialized so that parameters for these can be set
    public void init(int a) // a = 0 -> tx ; a = 1 -> rx
    { 
           // Name your project so that messaging will work within your project
           projectName = "DemoProject";
           set_output_text("Hello World! Press menu for options!");
           // Add sensors your project will use
           if(a==0){ 
        	   useSensors =  SOUND_OUT; // CAMERA;CAMERA_RGB;//WIFI_SCAN | SOUND_OUT; //GYROSCOPE;//SOUND_IN|SOUND_OUT;//WIFI_SCAN | ACCELEROMETER | MAGNETIC_FIELD | PROXIMITY | LIGHT;//TIME_SYNC|SOUND_IN;//TIME_SYNC | ACCELEROMETER | MAGNETIC_FIELD | PROXIMITY | LIGHT | SOUND_IN;
        	   clear_output_text();
        	   add_output_text_line("TX side");
        	   side=0;
           }
           if(a==1){ 
        	   useSensors=SOUND_IN; 
        	   add_output_text_line("RX side"); 
        	   side=1; 
           }                               
          
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
           int length_rxb =no_samp_period*2000*50;
           rx_buffer = new short[length_rxb];
           
           // Specify type of window function, 0 -> Rect window, 1 -> Hanning window 
           window =create_window(1);
                     
           // Modulate the training sequence
           ts_modQAM = modulateQAM_ts(ts_length,f1,levels); 

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
    	  //error = false;
    	  if(side==1 && error == false && state == RECEIVED) open_text_file(rx_filename);
    	  else if(side == 1 && error == true){ 
    		//  emergency_stop();	
    	  }
          trigger=-1;
          rx_ind=0;
          state=-1;
          clear_output_text();
          set_output_text("Stopped.");
          side=-1;
          file_loaded=false;
          error=false;
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
    		add_output_text_line("Stopped listening and started decoding...");
    		
    		// Time demodulation
    		long tstart0=System.currentTimeMillis();
    		
    		int margin = 20;
    		int block_length=2*levels*no_samp_period*(gb_length+ts_length+margin); // Block to do cross correlation
    	    double[] rx_bufferdouble = new double[rx_ind+4096-rx_ind%4096]; // Buffer of doubles
    	
    		for (int j=0;j<rx_ind;j++){
    			rx_bufferdouble[j] = (double) rx_buffer[j]; // Convert received samples to doubles
    		}
    		
    		// Equalizer
    		rx_bufferdouble = EQ(rx_bufferdouble); 	
    		
    		// Correlation function used to find training sequence
    		int index = maxXcorr(Arrays.copyOfRange(rx_bufferdouble, 0, block_length),ts_modQAM);
    		
    		// Send the received data to the decision algorithm, copy only data part
    		int decision[] = MQAMreceiver(f1,no_samp_period,Arrays.copyOfRange(rx_bufferdouble,index-margin,rx_bufferdouble.length));
    		 
    		// Convert binary stream back into a file
    		rx_filename = retrieveData(decision);

      	    // If an error occurs start again
      	    if (error == true){
      		    trigger=-1;
          	    state=-1;
          	    d_filename = null;
      	    }
      	    else{
      		
      		long tend0=System.currentTimeMillis();
      	    
      		// Display demodulation time
      	    add_output_text_line("Demodulation time = "+(float)(tend0-tstart0)/1000+"s");
      	    
      		// Phone vibrates with "File received!" pop-up message
      	    please_vibrate();
      	    
      	    // File is finished transferring
    		add_output_text_line("File was received correctly.");
    		add_output_text_line("Press the Menu button and select Open to see: "+rx_filename);
    		
    		d_filename = null;
          	bit_buffer = null;
    		trigger=-1;
    		//state=-1;
      	   }

    	}
    	}

    };       
   
    // Function used to detect when information is being transmitted
    @SuppressLint("NewApi")
    public void sound_in(long time, final short[] samples, int length)
    { 
    	final int threshold = 100;

    	// Variable to verify if transmission is done (detect only noise in buffer)
    	int continue_listening = 0;
    	if(trigger==0){
    		set_output_text("Only noise for the moment");
    		for(int i = 0 ; i < length; i++){
    			if(i==10){
    				add_output_text_line("Sample Amplitude="+samples[i]);
    			}
    			if(samples[i]>threshold){
    				clear_output_text();
    				trigger=1;
    				add_output_text_line("Started listening");
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

    				// Buffer of only noise, transmission done
    			}else{ 
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
    }

    // Function that stores that name of the file chosen
    public void stringFromBrowseForFile(String filename){
    	if(filename != null){
    		// Store name and extension of file in d_filename
    		d_filename=filename;

    		// Display file chosen for sending
    		add_output_text_line("You chose "+d_filename+" for sending.");
    	}else{
    		add_output_text_line("You canceled. Please try again by choosing a file.");
		}
	}
	
	// Function that saves the users input in a text file on the phone
    public void stringFromUser(String user_input)
    {
    	// On the transmission side
    	if (side==-1) {

        	String MessageFromUser = "MessageFromUser.txt";
    		
        	// Save string from user to a text file
        	save_to_file_s(MessageFromUser,user_input,user_input.length());
        	add_output_text_line("The file "+MessageFromUser+" was stored on the phone.");
    	}
    	
    	// On the receiver side
    	else{
        	// Opens received file
        	open_text_file(user_input);
    	}
    }

    // Implement reception of streaming sound here
    public void streaming_buffer_in(short[] buffer, int length, int senderId)
    {
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
 
 // Function that performs correlation
 public int maxXcorr(double[] x,double[] y){
	 double[] c = new double[x.length-y.length+2];
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

 
// Initialize cosine with specified frequency
 public static double[] initCosine(int f, int fs,int N){
	 double cosf[]=new double[N];
	 for(int k=0;k<N;k++){
		 cosf[k] = Math.cos(2 * Math.PI * (double) f * (double) k / ((double) fs));
	 }
	 return cosf;
 }
 
// Initialize sine with specified frequency
 public static double[] initSinusoid(int f, int fs,int N){
	 double sinf[]=new double[N];
	 for(int k=0;k<N;k++){
		 sinf[k] = Math.sin(2 * Math.PI * (double) f * (double) k / ((double) fs));
	 }
	 return sinf;
 }

 // Function that modulates all data and sends it
 void send_data(){
	 try{
		 add_output_text_line("Encoding...");

		 // Time total modulation
		 long t1s = System.currentTimeMillis(); 

		 SimpleInputFile in = new SimpleInputFile();

		 // Open and read text file containing guard band bits
		 in.open("/Redfiles/gb_test.txt");

		 gb_length = in.readInt();

		 int[] guard_stream = new int[gb_length*2*levels];
		 for(int i = 0;i<gb_length*2*levels;i++){
			 guard_stream[i]=in.readInt();
		 }
		 in.close();

	
	// Modulate the guard band, data signal, size of file, title of file and checksum of data
	double[] guard_signal =  MQAMmod(f1,guard_stream);
	double[] data_signal = MQAMmod(f1,bit_buffer);
	double[] size_data_signal = MQAMmod(f1,sizeofFile);
	double[] title_data_signal = MQAMmod(f1,titleofFile);
	double[] checksum_data_signal = MQAMmod(f1,checksumofFile);
	
	// End time of modulation
	long t1e = System.currentTimeMillis();
	// Display modulation time
	add_output_text_line("Modulation time: "+(float)(t1e - t1s)/1000+" s");
	
	// Size of total signal to be transmitted
	double[] tx_signal =new double[2*guard_signal.length+data_signal.length+ts_modQAM.length+bufferInt.length+title_data_signal.length+size_data_signal.length+checksum_data_signal.length];
	
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
	for(int i=0; i<checksum_data_signal.length; i++){
		tx_signal[current_position]=checksum_data_signal[i];
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

	// Create audiotrack
	final AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC,
            mysampleRate, AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT, bufferInt.length,
            AudioTrack.MODE_STREAM);
	
	// Find maximum value of tx_singal
	double max = 0;

	for(int i = 0;i<tx_signal.length;i++){
		if(Math.abs(tx_signal[i])>max) max=Math.abs(tx_signal[i]);
	}
	
	add_output_text_line("Sending file...");
	
	// Time transmission to calculate datarate
	long startTime = System.currentTimeMillis();
	
	// Play out the total modulated transmission signal
	for (int i = 0; i < tx_signal.length; i++) {
		tx_signal[i]=tx_signal[i]/max;
		play(tx_signal[i], audioTrack);
	}
	long endTime = System.currentTimeMillis();
	add_output_text_line("Transmission time: "+(float)(endTime - startTime)/1000+"s");
	 // Calculate data rate
	//float data_rate = ( ((float)(bit_buffer.length)/1024) / (float)(endTime - startTime))*1000;
	float data_rate = ( ((float)(bit_buffer.length+sizeofFile.length+titleofFile.length+checksumofFile.length)/1024) / (float)(endTime - startTime))*1000;
	//float data_rate = ( ((float)(bit_buffer.length+sizeofFile.length+titleofFile.length+checksumofFile.length)/1024) / tx_signal.length*mysampleRate);
	add_output_text_line("Done with transmission, data rate achieved ="+data_rate+" kbps");
	state=-1;
	}
	 catch(OutOfMemoryError E){
			add_output_text_line("The file is too big (over 36kB). Please press stop and send a smaller file.");
			error = true;
			state=-1;
			return;
		}
	 
	
	
	

}

// Function for playing sound
public void play(double in, AudioTrack at) {

    // Clip outside of range [-1, +1]
    if (in < -1.0){ add_output_text_line("I am clipping"); in = -1.0;}
    if (in > +1.0){  add_output_text_line("I am clipping"); in = +1.0;}

    // Convert to bytes
    short s = (short) ( MAX_16_BIT * in);
    bufferInt[bufferSize++] = (byte) s;
    bufferInt[bufferSize++] = (byte) (s >> 8);

    // Send to sound card if buffer is full        
    if (bufferSize >= bufferInt.length ) {
    	
    	at.write(bufferInt, 0, bufferInt.length);
        bufferSize = 0;
        at.play();
    }
}

public  short[] send_to_buffer(short[] rx_buffer, int length, short[] samples) {
	// Copy buffer
	for(int i=0;i<length;i++){
		rx_buffer[i+rx_ind]=samples[i];
	}
	if(rx_ind+2*length<=rx_buffer.length){
		rx_ind=rx_ind+length;
	}else{
		add_output_text_line("The buffer is full. Make sure the headset is correcly plugged.");
		trigger=2;
		rx_ind=rx_ind+length;
	}
	return rx_buffer;
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
    out.writeString(data);
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

// Function that converts as file into a binary stream of ones and zeros
public int[] data_buffer_bits(){
	if (init_done && (!file_loaded) && (!(d_filename==null))) {

		// Read file from plain file of samples in form of shorts
		the_file_contents=read_data_from_file(d_filename);
		
		// Calculate checksum value of bybte array
		C_sum_tx = checksum(the_file_contents,the_file_contents.length);
		
		// Store length of file in in int[] of bits
		String checksumofFile_s = Integer.toBinaryString((int) C_sum_tx);
		
		// Store length of file in in int[] of bits
		String sizeofFile_s = Integer.toBinaryString(the_file_contents.length);
		
		// Calculate the integer value of the length of the file contents
		int sizeofFile_i = Integer.valueOf(the_file_contents.length);
	
		// Warning message: File is too large
		
//		if (sizeofFile_i>sizeofFileLimit){
//			add_output_text_line("The file is too big (over 36kB). Please press stop and send a smaller file.");
//			error = true;
//			return null;
//		}
    
		
		// Store size of file in int[] of bits
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
		
		// Store checksum in int[] of bits
		byte[] checksumofFile_b = (checksumofFile_s.getBytes());	
		checksumofFile = new int[length_checksum];
		for (int k=0;k<checksumofFile_b.length;k++) {				
			for (int k1=0; k1<8; k1++){
				// Turn each byte into its corresponding bit representation
				checksumofFile [8*k+k1]=(checksumofFile_b[k] >> (7-k1) & 1);
			}
		}

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

// Function that converts binary stream of ones and zeros into the original file
public String retrieveData(int[] received){

	byte[] data_buffer_received = new byte[received.length/8];
	int receivedBitstemp[] = new int [8];

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
				add_output_text_line("Something went wrong. Please try again.");
				error = true;
				return null;
			}

		}

		state_two = 1;

	case SECOND:

		// Get title of file
		byte[] data_buffer_received_title = new byte[length_titleFile/8];
		
		try{
		for (int k=0;k<length_titleFile/8;k++){
		    if(data_buffer_received[k]!=0){
				data_buffer_received_title[k]=data_buffer_received[k];
			}
		}
		
		// Get size of file, try and catch used for index out of bounds error
		byte[] data_buffer_received_size = new byte[length_sizeFile/8];
		int counter=length_titleFile/8;
		while(data_buffer_received[counter]!=0){
			data_buffer_received_size[counter-length_titleFile/8]=data_buffer_received[counter];
			counter++;
		}

		// Get checksum of file
		byte[] data_buffer_received_checksum = new byte[length_checksum/8];
		int counter_n=(length_titleFile+length_sizeFile)/8;
		while(data_buffer_received[counter_n]!=0){
			data_buffer_received_checksum[counter_n-(length_titleFile+length_sizeFile)/8]=data_buffer_received[counter_n];
			counter_n++;
		}

		// Turn checksum of file into a string
		String data_buffer_received_checksum_c="";
		for (int k=(length_checksum+length_checksum)/8;k<counter_n;k++){
			data_buffer_received_checksum_c += (char) data_buffer_received_checksum[k-(length_checksum+length_checksum)/8];
		}
		
		// Turn checksum of file into a byte
		int checksum_rx;
			checksum_rx = Integer.parseInt(data_buffer_received_checksum_c,2);
		
		
		// Turn size of file into a string
		String data_buffer_received_size_c="";
		for (int k=length_titleFile/8;k<counter;k++){
			data_buffer_received_size_c += (char) data_buffer_received_size[k-length_titleFile/8];
		}
		
		// Turn size of file into a byte
		int size_i;
			size_i= Integer.parseInt(data_buffer_received_size_c,2);
		
		// Get data, remove size and title of file from the received buffer
		byte[] data_buffer_received_n = new byte[(received.length/8)-(length_titleFile+length_sizeFile+length_checksum)/8];
		for (int k=(length_titleFile+length_sizeFile+length_checksum)/8;k<(length_titleFile+length_sizeFile+length_checksum)/8+size_i;k++)
		        {
				data_buffer_received_n[k-(length_titleFile+length_sizeFile+length_checksum)/8]=data_buffer_received[k];
		        }
		
		byte[] data_buffer_received_nn = new byte[size_i];
		for (int i=0;i<size_i;i++){
				data_buffer_received_nn[i]=data_buffer_received_n[i];
			}
		
		// Compute checksum of received byte buffer and compare it to the transmitted check sum
		C_sum_rx = checksum(data_buffer_received_nn,data_buffer_received_nn.length);
        
        // If the checksums are not equal, transmit again
        
		if (checksum_rx!=C_sum_rx){
        	add_output_text_line("File was received with errors. Please try again. Checksum fails !");
        	error = true;
        	return null;
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

		// Create file
		FileOutputStream outFile;		
		File out = new File(Environment.getExternalStorageDirectory().getPath());

		// The file name to be written and stored
		String filename_w_ext =new String(data_buffer_received_title_n+"."+data_buffer_received_ext);

		File file = new File(out+"/"+data_buffer_received_title_n+"."+data_buffer_received_ext);
			outFile = new FileOutputStream(file);
			
		// Write the data of received buffer
			outFile.write(data_buffer_received_nn);
			outFile.close();
		return filename_w_ext;
	} // End try
		catch (ArrayIndexOutOfBoundsException e) {
			add_output_text_line("Could not decode file. Please try again.");
			error = true;
			return null; 
		    }	
		 catch (NumberFormatException e) {
			add_output_text_line("Something went wrong. Please try again.");
			error = true;
			return null;
		}
	     catch (IOException e) {
		   e.printStackTrace();
		   add_output_text_line("Something went wrong. Please try again.");
		   error = true;
		   return null; 
	      }
	
		
	}
	return null;
}

public void readFile(String received)
{
	SimpleInputFile in = new SimpleInputFile();
	in.open(received);
	String result = in.readString();
	while(result != null){
		result = in.readString();
	}
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
	//save_c_to_file("tx_const.txt",tx_const,tx_const.length);
	
	for(int i=0;i<L/(2*levels);i++){
		for(int ii=i*no_samp_period;ii<no_samp_period*(i+1);ii++){
			signal[ii]=window[ii-i*no_samp_period]*mconst[ii][0]*cosf1[ii-i*no_samp_period]-window[ii-i*no_samp_period]*mconst[ii][1]*sinf1[ii-i*no_samp_period];
			
		}
	}

	return signal;

}

public double[] modulateQAM_ts(int length,int f,int levels){
	SimpleInputFile in = new SimpleInputFile();
	
    in.open("/Redfiles/ts_test.txt"); 
    length = in.readInt();
    ts_length=length;
	final int [] ts = new int[length*2*levels];
	
	ts_stream=new int[length*2*levels];
	
	// Read file from sdcard
    for(int i=0; i<ts.length; i++){
           ts[i]=in.readInt(); 
           ts_stream[i] = ts[i];
    };
    
    in.close();
	final double[] mod_ts = MQAMmod(f,ts);
	ts_mod_const = mod_const_ts(ts,ts.length,levels);
	
	return mod_ts;
}
	

@SuppressLint("NewApi")
public int[] MQAMreceiver(int f,int n_sym,double[] r){
	
	double Vx[]=new double[r.length];
	double Vy[]=new double[r.length];

	for(int k=0;k<r.length;k++){
		Vx[k]=r[k]*cosf1[k%no_samp_period];
		Vy[k]=-r[k]*sinf1[k%no_samp_period];
	}
	
	double Hx[]  = LPfir(Vx);
	double Hy[] =  LPfir(Vy);
	
	int margin = 10;
	int block_length = (margin+ts_length)*no_samp_period;
	
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

	// Phase estimation
	Complex mconst[] = phase_estimation(Arrays.copyOfRange(Hxs, 0, current_position),Arrays.copyOfRange(Hys, 0, current_position),ts_mod_const,current_position);
	
	Complex[] demconst = new Complex[mconst.length];
	double theta = 0;
	
	double Ts = (double) no_samp_period / (double) mysampleRate;
	int batch_length = (int) Math.floor(0.02/Ts);
    int[] decision = new int[mconst.length*2*levels];
	current_position = 0;

	
	for(int k = 0 ; k < (int) Math.floor((double) mconst.length/(double) batch_length); k++){
		Complex[] mconst_phi =new Complex[batch_length];
		Complex complex_exp =new Complex(Math.cos(-phihat), Math.sin(-phihat));
		for(int q=(k*batch_length);q<(k+1)*batch_length;q++){
			mconst_phi[q-k*batch_length]=mconst[q];
			mconst_phi[q-k*batch_length]=mconst_phi[q-k*batch_length].times(complex_exp);
				
		}
		int decision_aux[] = demod_const(mconst_phi,levels);
		System.arraycopy(mconst_phi, 0, demconst, k*batch_length , batch_length);
		
		// Copies an array from the specified source array	
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
	
	// Copies an array from the specified source array
	System.arraycopy(decision_aux, 0, decision, current_position, decision_aux.length);
	
	// Current_position = current_position + decision_aux.length;
	//save_c_to_file("demconst.txt",demconst,demconst.length);
	
	//	int decision[] = demod_const(mconst,levels);
	return Arrays.copyOfRange(decision, ts_length*2*levels, decision.length);
}

@SuppressLint("NewApi")
public double[] LPfir(double[] input){
	SimpleInputFile in = new SimpleInputFile();
    in.open("/Redfiles/coeffs8.txt");
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
			in.open("/Redfiles/window8.txt");
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
	
	//save_c_to_file("mconst_before.txt",rx,length);

	for (int i=0;i<mconst_ts.length;i++){
		Complex x = rx[i].times(mconst[i].conjugate());
		double argx = x.phase();
		arg_sum=arg_sum+argx;
		double aux = (rx[i].abs())/(mconst[i].abs());
		ref = ref+aux;
	}

	ref = ref / (double) mconst_ts.length;
	phihat = arg_sum /(double) mconst_ts.length;

	Complex complex_exp =new Complex(1,0);
	Complex aux = new Complex(ref,0);
	Complex mconst_sym[] = new Complex[length];
	
	for(int i =0;i<mconst_sym.length;i++){
		mconst_sym[i]=new Complex(0,0);
	}
	for(int k=0;k<length;k++){
		
		mconst_sym[k] = rx[k].times(complex_exp);
		mconst_sym[k] = mconst_sym[k].divides(aux);
		
	}
	
	return mconst_sym;
	
}

// Equalizer
public double[] EQ(double[] input){
	SimpleInputFile in = new SimpleInputFile();
    in.open("/Redfiles/eqcoeffs8.txt");
    
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
	double arg_sum = 0;
	for (int i=0;i<current_position;i++){
		Complex x = mconst[i].times(demconst[i].conjugate());
		double argx = x.phase();
		arg_sum=arg_sum+argx;
		
	}
	arg_sum =  arg_sum / (double) current_position;
	
	return arg_sum;
	
}

// Function that computes the internet checksum of an array of bytes (ref: http://www.faqs.org/rfcs/rfc1071.html) 
long checksum(byte[] buf, int length) {
    int i = 0;
    long sum = 0;
    while (length > 0) {
        sum += (buf[i++]&0xff) << 8;
        if ((--length)==0) break;
        sum += (buf[i++]&0xff);
        --length;
    }

    return (~((sum & 0xFFFF)+(sum >> 16)))&0xFFFF;
}

}

