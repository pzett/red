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

import android.graphics.Bitmap;
//import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
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
    short newBuffer[] = new short[4096];
    Complex [] y_spectrum = new Complex[4096];
    double[] y_abs;
    float[] y_absf;
    private final int duration = 3; // seconds
    private final int mysampleRate = 44100;
    private final int numSamples = duration * mysampleRate;
    private final double sample[] = new double[numSamples];
    
    boolean sound_inStarted = false;
//    private final double freqOfTone = 440; // hz  
    private final byte generatedSnd[] = new byte[2 * numSamples];
    
       // This is called before any other functions are initialized so that parameters for these can be set
    public void init()
    { 
           // Name your project so that messaging will work within your project
           projectName = "DemoProject";
   
           // Add sensors your project will use
           useSensors = SOUND_IN ;// CAMERA;//CAMERA_RGB;//WIFI_SCAN | SOUND_OUT; //GYROSCOPE;//SOUND_IN|SOUND_OUT;//WIFI_SCAN | ACCELEROMETER | MAGNETIC_FIELD | PROXIMITY | LIGHT;//TIME_SYNC|SOUND_IN;//TIME_SYNC | ACCELEROMETER | MAGNETIC_FIELD | PROXIMITY | LIGHT | SOUND_IN;
                                                    
          
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
           introText = "This is Assignment 5\nPress Menu to select any option";
     
           // Stuff for the playing of sound example
           init_done=true;
           buffer=new short[1024]; // 1024 samples sent to codec at a time
           Complex cm = new Complex(0,0);
          
           for(int y=0;y<y_spectrum.length;y++){
           y_spectrum[y]= cm;
          }

    }

    // This is called when the user presses start in the menu, reinitialize any data if needed
    public void start()
    {    
           // Start audio recording
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
   /*
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
   */
    public void sound_in(long time, final short[] samples, int length)
    {                  
           // Task 4 create the echo
          
           //set_output_text("buffer size="+length);
           //sound_out(samples,length);
          /*
           for(int ind =0;ind<longBuffer.length-length;ind++)
           {
            longBuffer[ind] = longBuffer[ind+4096];
           }
          for(int ind = 0 ; ind< 4096;ind++)        
           {
            longBuffer[ind + longBuffer.length-length] = samples[ind];
           }   
           for(int ind =0;ind<4096;ind++)
           {
            delaySamples[ind] = (short) (longBuffer[ind] + samples[ind]);
           }           
       */
          for(int ind =0;ind<4096;ind++)
           {
            delaySamples[ind] = (short) (samples[ind]);
           }
           
          // sound_out(delaySamples,length);
          
           Complex[] x = new Complex[length];
           //set_output_text("buffer size="+length+"sample="+samples[2]);
           //sound_out(samples,length);
           for (int i = 0; i < length; i++) {
	            x[i] = new Complex(delaySamples[i], 0); 
	           	        }
           
           sound_inStarted = true;
           
           y_spectrum = fft(x);
           //System.out.printf("AK: inside sound in taking fft "+y_spectrum[0].abs());
           
           
          // set_output_text("length =" +y_spectrum.length);
          //add_output_text_line("abs =" +y_spectrum[2].abs());
         //for (int j = 0; j < y_spectrum.length; j++) {
           
           //y_absf[j]=(float) y_spectrum[j].abs()/100;
      
          // add_output_text_line("abs =" +(float) y_spectrum[j].abs()/100);
           
        // }
    }
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
          
    	plotCanvas.drawARGB ( 255, 23, 230, 25); 
    	
    	final Paint paint = new Paint();
    	//final float start = dispwidth/24;
    	//final float end = dispheight - 1;
    	final float start = 100;
    	final float end = 10;
    	final float temp = 2;
    	final float dHeight1 = 150;
    	final float dHeight2 = 600;
    	final float length = 4096;
    	paint.setAntiAlias(true);             
    	paint.setDither(true);             
    	paint.setStyle(Paint.Style.STROKE);              
    	paint.setStrokeJoin(Paint.Join.MITER);              
    	paint.setStrokeCap(Paint.Cap.SQUARE);             
    	paint.setColor(Color.YELLOW);             
    	paint.setStrokeWidth(1);           
    	paint.setTextSize(350);             
    	paint.setAlpha(100);            
    	plotCanvas.drawColor(Color.BLACK);     
      
        // Calculate a scaling factor.  We want a degree of AGC, but not
        // so much that the waveform is always the same height.  Note we have
        // to take bias into account, otherwise we could scale the signal
        // off the screen.
    	/*
    	float range = 10;
        float scale = (float) Math.pow(1f / (range / 6500f), 0.7) / 16384 * dHeight;
        if (scale < 0.001f | Float.isInfinite(scale))
            scale = 0.001f;
        else if (scale > 1000f)
            scale = 1000f;
    	*/
    	// Draw axes
    	plotCanvas.drawLine(20, 150, 600, 150, paint);
    	plotCanvas.drawLine(20, 1200, 600, 1200, paint);
    	plotCanvas.drawLine(20, 0, 20, 1200, paint);
    	//plotCanvas.drawLine(startX, startY, stopX, stopY, paint);
        
    	// Draw waveform    	
    	//synchronized (this){
    	
    	for (int i = 0; i < 600; ++i) {
            final float x =  20 + i;
            final float y;
            
            if(delaySamples[i]<0){
            	 y = - (delaySamples[i]/50)+150;
            }
            else{
                y = 150 - (delaySamples[i]/50);
            }
            plotCanvas.drawLine(x, dHeight1, x, y, paint);    	
    	}
    	
    	//}
    	
    	// Plot Spectrum
    	
    	//add_output_text_line("abs =" +(float) y_spectrum[0].abs()/100);	
    	//System.out.println("AK: spec len "+y_spectrum.length); 
    	paint.setColor(Color.YELLOW);             
    	paint.setStrokeWidth(45); 
    	if(sound_inStarted == true){
    		  
       int[] numbers = {19,28,37,46,55,64};
        	 
    	for (int i : numbers) {
            final float x =  5*(i)-55;       
        //   y = 600 - (float)( y_spectrum[i].abs()/100);
          plotCanvas.drawLine(x, dHeight2, x, 600 - (float)( y_spectrum[i].abs()/3000), paint);
    	}
    }
    
    
    } 
   
   
    public void stringFromUser(String user_input){       
           set_output_text(user_input);
           int in = Integer.valueOf(user_input);
           genTone(in);
           playSound();
          
          
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
    int no_of_real;
    double [] in_values;
    double [] out_values;


     
    SimpleOutputFile out = new SimpleOutputFile();
    SimpleInputFile in = new SimpleInputFile();
   
    in.open("indata.txt");             
    out.open("outdata.txt");
   
    // Read data from input file 
    no_of_real=in.readInt();
    in_values=new double[no_of_real];
    // Read file from sdcard
    for(int i=0; i<in_values.length; i++){
           in_values[i]=in.readDouble(); 
    };

   
     // Call the function to be tested 
    out_values=square(in_values);
   
    // Write file on sdcard 
    for(int i=0; i<in_values.length; i++){
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
             AudioTrack.MODE_STATIC);
     audioTrack.write(generatedSnd, 0, generatedSnd.length);
     audioTrack.play();
 }
 

 public void spectrum(){
 	//float newBuffer[] = null;
 	//for(int i3=0;i3<delaySamples.length;i3++){ 
	 
	// newBuffer = fft(delaySamples);
 	//Math.abs(delaySamples);
     //}
 	
 }

	    // compute the FFT of x[], assuming its length is a power of 2
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


	    // compute the inverse FFT of x[], assuming its length is a power of 2
	    public static Complex[] ifft(Complex[] x) {
	        int N = x.length;
	        Complex[] y = new Complex[N];

	        // take conjugate
	        for (int i = 0; i < N; i++) {
	            y[i] = x[i].conjugate();
	        }

	        // compute forward FFT
	        y = fft(y);

	        // take conjugate again
	        for (int i = 0; i < N; i++) {
	            y[i] = y[i].conjugate();
	        }

	        // divide by N
	        for (int i = 0; i < N; i++) {
	            y[i] = y[i].times(1.0 / N);
	        }

	        return y;

	    }

	    // compute the circular convolution of x and y
	    public static Complex[] cconvolve(Complex[] x, Complex[] y) {

	        // should probably pad x and y with 0s so that they have same length
	        // and are powers of 2
	        if (x.length != y.length) { throw new RuntimeException("Dimensions don't agree"); }

	        int N = x.length;

	        // compute FFT of each sequence
	        Complex[] a = fft(x);
	        Complex[] b = fft(y);

	        // point-wise multiply
	        Complex[] c = new Complex[N];
	        for (int i = 0; i < N; i++) {
	            c[i] = a[i].times(b[i]);
	        }

	        // compute inverse FFT
	        return ifft(c);
	    }


	    // compute the linear convolution of x and y
	    public static Complex[] convolve(Complex[] x, Complex[] y) {
	        Complex ZERO = new Complex(0, 0);

	        Complex[] a = new Complex[2*x.length];
	        for (int i = 0;        i <   x.length; i++) a[i] = x[i];
	        for (int i = x.length; i < 2*x.length; i++) a[i] = ZERO;

	        Complex[] b = new Complex[2*y.length];
	        for (int i = 0;        i <   y.length; i++) b[i] = y[i];
	        for (int i = y.length; i < 2*y.length; i++) b[i] = ZERO;

	        return cconvolve(a, b);
	    }

	    // display an array of Complex numbers to standard output
	    public static void show(Complex[] x, String title) {
	        System.out.println(title);
	        System.out.println("-------------------");
	        for (int i = 0; i < x.length; i++) {
	            System.out.println(x[i]);
	        }
	        System.out.println();
	    }


	   /*********************************************************************
	    *  Test client and sample execution
	    *
	    *  % java FFT 4
	    *  x
	    *  -------------------
	    *  -0.03480425839330703
	    *  0.07910192950176387
	    *  0.7233322451735928
	    *  0.1659819820667019
	    *
	    *  y = fft(x)
	    *  -------------------
	    *  0.9336118983487516
	    *  -0.7581365035668999 + 0.08688005256493803i
	    *  0.44344407521182005
	    *  -0.7581365035668999 - 0.08688005256493803i
	    *
	    *  z = ifft(y)
	    *  -------------------
	    *  -0.03480425839330703
	    *  0.07910192950176387 + 2.6599344570851287E-18i
	    *  0.7233322451735928
	    *  0.1659819820667019 - 2.6599344570851287E-18i
	    *
	    *  c = cconvolve(x, x)
	    *  -------------------
	    *  0.5506798633981853
	    *  0.23461407150576394 - 4.033186818023279E-18i
	    *  -0.016542951108772352
	    *  0.10288019294318276 + 4.033186818023279E-18i
	    *
	    *  d = convolve(x, x)
	    *  -------------------
	    *  0.001211336402308083 - 3.122502256758253E-17i
	    *  -0.005506167987577068 - 5.058885073636224E-17i
	    *  -0.044092969479563274 + 2.1934338938072244E-18i
	    *  0.10288019294318276 - 3.6147323062478115E-17i
	    *  0.5494685269958772 + 3.122502256758253E-17i
	    *  0.240120239493341 + 4.655566391833896E-17i
	    *  0.02755001837079092 - 2.1934338938072244E-18i
	    *  4.01805098805014E-17i
	    *
	    *********************************************************************/

	    public static void fft2(String[] args) { 
	        int N = Integer.parseInt(args[0]);
	        Complex[] x = new Complex[N];

	        // original data
	        for (int i = 0; i < N; i++) {
	            x[i] = new Complex(i, 0);
	            x[i] = new Complex(-2*Math.random() + 1, 0);
	        }
	        show(x, "x");

	        // FFT of original data
	        Complex[] y = fft(x);
	        show(y, "y = fft(x)");

	        // take inverse FFT
	        Complex[] z = ifft(y);
	        show(z, "z = ifft(y)");

	        // circular convolution of x with itself
	        Complex[] c = cconvolve(x, x);
	        show(c, "c = cconvolve(x, x)");

	        // linear convolution of x with itself
	        Complex[] d = convolve(x, x);
	        show(d, "d = convolve(x, x)");
	    }



}