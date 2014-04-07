/* Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
* This software is provided  抋s is�. It is free to use for non-commercial purposes.
* For commercial purposes please contact Peter H鋘del (peter.handel@ee.kth.se)
* for a license. For non-commercial use, we appreciate citations of our work,
* please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
* for how information on how to cite. */ 

package se.kth.android.StudentCode;

//import java.util.ArrayList;
//import java.util.Arrays;
//import java.util.Date;
import java.util.List;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.lang.Object;


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
import android.os.Handler;


public class StudentCode extends StudentCodeBase {
	

	  /* Varibles need for plaing sound example */
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
    final static int no_samp_period = 100;
    final static int f1=2500;
    final static int f2=3500;
    final static double[] cosf1 =initCosine(f1, mysampleRate,no_samp_period);
    final static double[] cosf2 =initCosine(f2, mysampleRate,no_samp_period);
    private static final double MAX_16_BIT = Short.MAX_VALUE; 
    private static final int SAMPLE_BUFFER_SIZE = 4096;
    private static byte[] bufferInt;         // our internal buffer
    private static int bufferSize = 0;    // number of samples currently in internal buffer
    private static int bufferLength = 4096; 
    private static final int BYTES_PER_SAMPLE = 2;                // 16-bit audio
    private static final int BITS_PER_SAMPLE = 16;                // 16-bit audio
    
       // This is called before any other functions are initialized so that parameters for these can be set
    public void init()
    { 
           // Name your project so that messaging will work within your project
           projectName = "DemoProject";
   
           // Add sensors your project will use
           useSensors =  SOUND_OUT;// CAMERA;//CAMERA_RGB;//WIFI_SCAN | SOUND_OUT; //GYROSCOPE;//SOUND_IN|SOUND_OUT;//WIFI_SCAN | ACCELEROMETER | MAGNETIC_FIELD | PROXIMITY | LIGHT;//TIME_SYNC|SOUND_IN;//TIME_SYNC | ACCELEROMETER | MAGNETIC_FIELD | PROXIMITY | LIGHT | SOUND_IN;
                                                    
          
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
           introText = "This is for xcorr computation";
     
           // Stuff for the playing of sound example
           init_done=true;
           buffer=new short[1024]; // 1024 samples sent to codec at a time
           userInputString=true;
           bufferInt = new byte[SAMPLE_BUFFER_SIZE * BYTES_PER_SAMPLE];
           

           
           
           

    }

    // This is called when the user presses start in the menu, reinitialize any data if needed
    public void start()
    {    
           // Start audio recording
    	 int corr = maxXcorr(inputxcorr,inputycorr); 
    	add_output_text_line("index="+corr);
    	send_data();
    	 
    }
     
    // This is called when the user presses stop in the menu, do any post processing here
    public void stop()      
    {
          
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
    public void process()
    { 
           //set_output_text(""+gyroData+"\n"+gpsData + "\n"+triggerTime+"\n"+ magneticData+"\n"+proximityData+"\n"+lightData+"\n"+screenData+"\n"+messageData);           //set_output_text(debug_output+"\n");
           //set_output_text(wifi_ap);
          
    	//Complex[] y =   fft(input);
    	
    	  Complex a =new Complex(2,3);
          Complex b =new Complex(1,6);
          //set_output_text("\n b + a        = " + b.plus(a));
          //int corr = maxXcorr(inputxcorr,inputycorr);
          //for(int ind =0;ind<y.length;ind++)
          //{
        	  //add_output_text_line("y["+ind+"]="+y[ind]);
        	 
       //   }
       //  set_output_text(""+sample+"\n"+Q+ "\n");
         // add_output_text_line("index="+corr);
        //show(y, "y = fft(x)");
           // Sound example. Uncomment to play sound from the file data/lga.dat formatted as described in the slides.             
           //playsoundexample();
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
           // Task 4 create the echo
    	Complex[] x = new Complex[length];
           set_output_text("buffer size="+length+"sample="+samples[2]);
           //sound_out(samples,length);
           for (int i = 0; i < length; i++) {
	            x[i] = new Complex(samples[i], 0);
	           	        }
           Complex[] y =   fft(x);
           for(int ind =0;ind<y.length;ind++)
           {
         	  add_output_text_line("y["+ind+"]="+Math.round(y[ind].abs()*100)/100.0);
         	  if(ind%9==0){
         		 clear_output_text();
         	  }
         		  
           }
          
           //sound_out(delaySamples,length);
          
          
    /*    try {
              Thread.sleep(1000);
           } catch (InterruptedException e) {
              e.printStackTrace();
           }
           */
           //new Timer().schedule(sound_out(samples,samples.length),1000);
           //sound_out(samples,samples.length);
           //echoPlay(samples,samples.length);
           // start a timer and do sound out in the fired event 
    //     set_output_text(Integer.toString(samples[samples.length]));
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
   
   
    public void stringFromUser(String user_input){       
           set_output_text(user_input);
           int in = Integer.valueOf(user_input);
           //genTone(in);
           //playSound();
          square(in);
       
         
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
    out_values=goertzel(f1,f2,n,in_values);
   
    // Write file on sdcard 
    for(int i=0; i<out_values.length; i++){
           out.writeDouble(out_values[i]);
    };
            
    
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
	 int fs=44100;
	 
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
 	double a=0;
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
 
 public static double[] initCosine(int f, int fs,int N){
	 double cosf[]=new double[N];
	 for(int k=0;k<N;k++){
		 cosf[k] = Math.cos(2 * Math.PI * f * k / (fs));
	 }
	 return cosf;
 }
 
void send_data(){
	int Nb = 5000;
	int[] bit_stream = new int[Nb];
	for(int i = 0;i<Nb;i++){
		bit_stream[i]=Math.round((float) Math.random());
		}
	double[] signal = FSK_mod(f1,f2,bit_stream);
	
	final AudioTrack audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC,
            mysampleRate, AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT, bufferInt.length,
            AudioTrack.MODE_STREAM);
	
	
    for (int i = 0; i < signal.length; i++) {
        play(signal[i], audioTrack);
    }
    
    
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



}
