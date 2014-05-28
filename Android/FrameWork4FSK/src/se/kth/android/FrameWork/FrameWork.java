/* Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
* This software is provided  ’as is’. It is free to use for non-commercial purposes.
* For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
* for a license. For non-commercial use, we appreciate citations of our work,
* please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
* for how information on how to cite. */ 

package se.kth.android.FrameWork;
  
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantLock;
import android.app.AlertDialog;
import android.media.AudioManager;

import edu.dhbw.andar.CameraPreviewHandler;

import se.kth.android.GroupRed2014App4FSK.R;
import se.kth.android.StudentCode.StudentCode;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
//import android.graphics.ImageFormat;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.hardware.Camera.PreviewCallback;
import android.hardware.Camera.AutoFocusCallback;
import android.hardware.Camera.Size;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.media.AudioFormat;
//import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaRecorder;
import android.media.AudioRecord.OnRecordPositionUpdateListener;
import android.media.AudioTrack.OnPlaybackPositionUpdateListener;
import android.net.Uri;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Environment;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.webkit.MimeTypeMap;
import android.widget.Button;
//import android.view.SurfaceHolder;
import android.widget.TextView;
import android.widget.EditText;


public class FrameWork extends Activity implements OnRecordPositionUpdateListener, OnPlaybackPositionUpdateListener, SensorEventListener, PreviewCallback, LocationListener {
	AudioRecord  recorder = null;
	AudioTrack player = null;
  
	Thread t1 = null; 
	boolean active = false;
	PlotView plotView = null;
	TextView textView = null;
	Thread guiTriggerThread = null;
	View buttonView = null;
	private LocationManager mLocationManager = null;

	  
	StudentCode studentCode = null;
	public SynchronizedTime synchronizedTime = null;
	 
	private BufferedOutputStream logFile; 

	Camera camera = null;
	
	int recordBufferSize;
	int recordBuffers = 32;
	Thread studentProcessThread;
	int playBufferSize;

	
	Thread wifiScanThread;


	ReentrantLock concurrentLock = new ReentrantLock(); 
	void lock()
	{
		if(studentCode.useConcurrentLocks)
			concurrentLock.lock();
	}
	
	void unlock()
	{
		if(studentCode.useConcurrentLocks)
			concurrentLock.unlock();
	}
	
	enum CameraState  { IDLE, STARTED, RECORDING, PLAYING };
	CameraState cameraState = CameraState.IDLE;
	protected BufferedOutputStream recordingFile;
	protected BufferedInputStream replayFile;
	File[] rfiles;
	protected int replaySizeX;
	protected int replaySizeY;	
	Context context;
    @Override
    public void onCreate(Bundle savedInstanceState) {
    	
    	
        super.onCreate(savedInstanceState);
        context = this;
        setContentView(R.layout.main);
        textView = (TextView)findViewById(R.id.textview);
        plotView = (PlotView)findViewById(R.id.oscview);
        plotView.fw = this;
        
        buttonView = (View)findViewById(R.id.buttons);
        studentCode = new StudentCode();
        
        
        
        AudioManager am = (AudioManager) getSystemService(AUDIO_SERVICE);
		    int max_value =am.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
		    int volume_level= am.getStreamVolume(AudioManager.STREAM_MUSIC);
		    am.setStreamVolume(AudioManager.STREAM_MUSIC,(int) Math.floor(max_value/2)+3, 0);
		    boolean meow = am.isWiredHeadsetOn();
		    if(meow == false){
		    	
	        		AlertDialog.Builder builder = new AlertDialog.Builder(this);
	        		builder.setMessage("You must plug the headset.")
	        		       .setCancelable(false)
	        		       .setPositiveButton("OK", new DialogInterface.OnClickListener() {
	        		           public void onClick(DialogInterface dialog, int id) {
	        		        	  
	        		           }
	        		       });
	        		AlertDialog alert = builder.create();
	        		alert.show();
	        			    }
		    
		    
        studentCode.init(-1);
        
        if(studentCode.test_harness())
            System.exit(0);

        synchronizedTime = new SynchronizedTime();

        if(studentCode.ntpServer != null && (studentCode.useSensors & StudentCode.TIME_SYNC) == StudentCode.TIME_SYNC)
        	synchronizedTime.Init(studentCode.ntpServer);
        
        guiTriggerThread = new Thread(new Runnable() { 
        	synchronized public void run() 
        	{ 
        		while(true)
        		{ 
        			
        			try {
       					plotView.postInvalidate();
      					textView.post(new Runnable() {
        					public void run()
        					{
         						//+"\n"+(plotView.maxOffset-plotView.minOffset)*1000f/0x100000000L);
         						  
         						textView.setText(studentCode.textOutput);
         					}
        				});
						wait(100);
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
        		}
        	}
        	});
        guiTriggerThread.start();        

        studentProcessThread = new Thread(new Runnable() { 
        	synchronized public void run() 
        	{ 
        		while(true)
        		{
        			try {
    			        lock();
        				if(active)    
        					studentCode.process();
        		        unlock();
        				wait(studentCode.processInterval);   
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
        		}
        	}
        	});
        studentProcessThread.start();        
        
        SensorManager sensorManager = (SensorManager) this.getSystemService(SENSOR_SERVICE);
        List<Sensor> sensorList = sensorManager.getSensorList(Sensor.TYPE_ALL);
       
        if((studentCode.useSensors & StudentCode.ACCELEROMETER) == StudentCode.ACCELEROMETER)
        {
	        for (Sensor sensor : sensorList) {
	        	if (sensor.getType()==Sensor.TYPE_ACCELEROMETER)
	        		sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_FASTEST);
	        };		
        }        		
        if((studentCode.useSensors & StudentCode.GYROSCOPE) == StudentCode.GYROSCOPE)
        {
	        for (Sensor sensor : sensorList) {
	        	if (sensor.getType()==Sensor.TYPE_GYROSCOPE)
	        		sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_FASTEST);
	        };		
        }        		
        if((studentCode.useSensors & StudentCode.MAGNETIC_FIELD) == StudentCode.MAGNETIC_FIELD)
        {
	        for (Sensor sensor : sensorList) {
	        	if (sensor.getType()==Sensor.TYPE_MAGNETIC_FIELD)
	        		sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_FASTEST);
	        };		
        }        		
        if((studentCode.useSensors & StudentCode.PROXIMITY) == StudentCode.PROXIMITY)
        {
	        for (Sensor sensor : sensorList) {
	        	if (sensor.getType()==Sensor.TYPE_PROXIMITY)
	        		sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_FASTEST);
	        };		
        }        		
        if((studentCode.useSensors & StudentCode.LIGHT) == StudentCode.LIGHT)
        {
	        for (Sensor sensor : sensorList) {
	        	if (sensor.getType()==Sensor.TYPE_LIGHT)
	        		sensorManager.registerListener(this, sensor, SensorManager.SENSOR_DELAY_FASTEST);
	        };		
        }        		
         
        if((studentCode.useSensors & StudentCode.GPS) == StudentCode.GPS)
        {
           	mLocationManager = (LocationManager) getSystemService(LOCATION_SERVICE);
        	if(!mLocationManager.isProviderEnabled(LocationManager.GPS_PROVIDER))
        	{
        		AlertDialog.Builder builder = new AlertDialog.Builder(this);
        		builder.setMessage("You must enable GPS positioning in settings.")
        		       .setCancelable(false)
        		       .setPositiveButton("OK", new DialogInterface.OnClickListener() {
        		           public void onClick(DialogInterface dialog, int id) {
        		        	   startActivityForResult(new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS), 0);
        		           }
        		       });
        		AlertDialog alert = builder.create();
        		alert.show();
        	}

        }

        if(((studentCode.useSensors & StudentCode.CAMERA) == StudentCode.CAMERA || (studentCode.useSensors & StudentCode.CAMERA_RGB) == StudentCode.CAMERA_RGB)) {
        if (studentCode.useCameraGUI) 
        {
        	
           	Button b = (Button)findViewById(R.id.start);
        	b.setOnClickListener(new View.OnClickListener() {
				
				public void onClick(View v) {
					if(cameraState == CameraState.IDLE && camera != null)
					{
						cameraState = CameraState.STARTED;
						camera.startPreview();
						if (studentCode.useAutoFocus) {
						AutoFocusCallback autoFocusCallback = new 
								AutoFocusCallback() {
							   @Override
							public void onAutoFocus(boolean success, 
								Camera camera) { camera.autoFocus(this);
			              }
						  };								                         
						  camera.autoFocus(autoFocusCallback );
						};



					} 
				}    
			});
           	b = (Button)findViewById(R.id.stop);
        	b.setOnClickListener(new View.OnClickListener() {
				
				public void onClick(View v) {
					if(cameraState == CameraState.PLAYING && replayFile != null)
					{
						cameraState = CameraState.IDLE;
						try {
							replayFile.close();
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						replayFile = null;
					}
					if(cameraState == CameraState.RECORDING && camera != null)
					{
						cameraState = CameraState.STARTED;
						if(recordingFile!=null)
						{
							try {
								recordingFile.flush();
								recordingFile.close();
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							recordingFile = null;
						}
					}
					if(cameraState == CameraState.STARTED && camera != null)
					{
						cameraState = CameraState.IDLE;
						if (studentCode.useAutoFocus) 
							camera.cancelAutoFocus();
						camera.stopPreview();
					}
				}
			});
         	b = (Button)findViewById(R.id.record);
        	b.setOnClickListener(new View.OnClickListener() {
				
				public void onClick(View v) {
					if(cameraState == CameraState.STARTED)
					{
						cameraState = CameraState.RECORDING;
						try {
							File dir = new File(Environment.getExternalStorageDirectory().getPath()+"/recordings/");
							dir.mkdir();
							String recName = new String(dir+ "/video"+
							new SimpleDateFormat("yyyyMMddHHmm").format(new Date()) + ".rec");
							recordingFile = new BufferedOutputStream(new FileOutputStream(recName));

						} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
						
						}

					}

				}
			});
         	b = (Button)findViewById(R.id.replay);
        	b.setOnClickListener(new View.OnClickListener() {
				
				public void onClick(View v) {
					if(cameraState == CameraState.IDLE && replayFile == null)
					{
						
						File dir = new File(Environment.getExternalStorageDirectory().getPath()+"/recordings/");
	            		rfiles = dir.listFiles();
	            		CharSequence[] rfilenames = new CharSequence[rfiles.length];
	            		for(int i=0;i<rfiles.length;i++)
	            			rfilenames[i] = rfiles[i].getName();
	                	AlertDialog.Builder rbuilder = new AlertDialog.Builder(context);
	                	rbuilder.setTitle("Select recording");
	                	rbuilder.setItems(rfilenames, new DialogInterface.OnClickListener() {


							public void onClick(DialogInterface dialog, int item) {
	                	    	try {
									replayFile = new BufferedInputStream(new FileInputStream(rfiles[item]));
									cameraState = CameraState.PLAYING;
									Thread replayThread = new Thread(new Runnable() {
										
										public void run() {
											while(cameraState == CameraState.PLAYING)
											{
												
												try {
													int replaySizeX = replayFile.read()*256+replayFile.read();
													int replaySizeY = replayFile.read()*256+replayFile.read();
													if(replaySizeX>0 && replaySizeY>0)
													{
														int bpp = 1;
														if((studentCode.useSensors & StudentCode.CAMERA_RGB) == StudentCode.CAMERA_RGB)
															bpp = 3;
														byte[] frame = new byte[replaySizeX*replaySizeY*bpp]; 
														replayFile.read(frame);
														if((studentCode.useSensors & StudentCode.CAMERA) == StudentCode.CAMERA)
															studentCode.camera_image(frame, replaySizeX, replaySizeY);
														else
															studentCode.camera_image_rgb(frame, replaySizeX, replaySizeY);
													}
													
												} catch (IOException e) {
													// TODO Auto-generated catch block
													e.printStackTrace();													
												};
											}
										}
									});
									replayThread.start();

								} catch (FileNotFoundException e) {
								} catch (IOException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
	                	    }
	                	});
	                	AlertDialog ralert = rbuilder.create();
	                	ralert.show();	
	                	
	                }

				}
			});
        	
        	 

        	camera = Camera.open();
        	camera.setPreviewCallback(this);
        } else {
        	camera = Camera.open();
        	camera.setPreviewCallback(this);        	
        	camera.startPreview();
        	cameraState=CameraState.STARTED;

        	
        };};
 
        if((studentCode.useSensors & StudentCode.WIFI_SCAN) == StudentCode.WIFI_SCAN)
        {
        	IntentFilter intentFilter = new IntentFilter();
	        intentFilter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION);
	        registerReceiver(new BroadcastReceiver(){
					@Override
					public void onReceive(Context c, Intent i){
	                        WifiManager w = (WifiManager) c.getSystemService(Context.WIFI_SERVICE);
	                        List<ScanResult> wsrl = w.getScanResults(); // Returns a <list> of scanResults
	                        lock();
	                        studentCode.wifi_ap(synchronizedTime.nowNetworkTimeNanos(),wsrl);
	                        unlock();
	                        String s="W;"+wsrl+"\n";
	            			if(studentCode.loggingOn)
	            				try {
	            			    	if(logFile != null && s != null)
	            			    		logFile.write(s.getBytes(),0,s.length());
	            				} catch (IOException e) {
	            					e.printStackTrace();
	            				}	                        
	                }
	        	}, intentFilter );
	
	        wifiScanThread = new Thread(new Runnable() { 
	        	synchronized public void run() 
	        	{ 
	        		WifiManager wm = (WifiManager) getSystemService(Context.WIFI_SERVICE);
	        		while(true)
	        		{
	        			try {
	        				if(active)      					     					
	        					wm.startScan();
	        				wait(1000);   
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
	        		}
	        	}
	        	});
	        wifiScanThread.start();
        }

        if(studentCode.textOutput == null)
        {
        	if(studentCode.introText == null)
        	{
	        	String s = studentCode.projectName + "\nPress menu/start to begin\n";
	        	if(studentCode.loggingOn)
	        		s+="Logging is on\n";
	        	else
	        		s+="Logging is off\n";
	            if((studentCode.useSensors & StudentCode.GPS) == StudentCode.GPS)
	            	s+="GPS enabled\n";
	            if((studentCode.useSensors & StudentCode.ACCELEROMETER) == StudentCode.ACCELEROMETER)
	            	s+="Accelerometer enabled\n";
	            if((studentCode.useSensors & StudentCode.GYROSCOPE) == StudentCode.GYROSCOPE)
	            	s+="Gyroscope enabled\n";
	            if((studentCode.useSensors & StudentCode.MAGNETIC_FIELD) == StudentCode.MAGNETIC_FIELD)
	            	s+="Magnetic field sensor enabled\n";
	            if((studentCode.useSensors & StudentCode.PROXIMITY) == StudentCode.PROXIMITY)
	            	s+="Proximity sensor enabled\n";
	            if((studentCode.useSensors & StudentCode.LIGHT) == StudentCode.LIGHT)
	            	s+="Light sensor enabled\n";
	            if((studentCode.useSensors & StudentCode.SOUND_IN) == StudentCode.SOUND_IN)
	            	s+="Microphone input enabled\n";
	            if((studentCode.useSensors & StudentCode.TIME_SYNC) == StudentCode.TIME_SYNC)
	            	s+="Time synchronization enabled\n";
	            if((studentCode.useSensors & StudentCode.WIFI_SCAN) == StudentCode.WIFI_SCAN)
	            	s+="WiFi scan enabled\n";
	            if((studentCode.useSensors & StudentCode.CAMERA) == StudentCode.CAMERA || (studentCode.useSensors & StudentCode.CAMERA_RGB) == StudentCode.CAMERA_RGB)
	            	s+="Camera enabled\n";
	            if(studentCode.streamingSink)
		            	s+="Streaming buffer receiver\n";
	
	            studentCode.textOutput = s;
        	}
        	else
        		studentCode.textOutput = studentCode.introText;
        }
        
 
        
         }
	@Override
	protected void onDestroy() {
		if(recorder != null)
			recorder.release();
		if(player != null)
			player.release();
		super.onDestroy();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		menu.add(0,1,0,"TX");
		menu.add(0,2,0,"Kill");
		menu.add(0,4,0,"RX");
		if (studentCode.userInputString) {
			menu.add(0,3,0,studentCode.userInputStringMenuItem);
		};	
		
		return super.onCreateOptionsMenu(menu);
	}
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) 
		{
		case 4:{
			if(!active)
			{
				item.setTitle("Open");
				studentCode.init(1);

				
			    if((studentCode.useSensors & StudentCode.CAMERA) == StudentCode.CAMERA || (studentCode.useSensors & StudentCode.CAMERA_RGB) == StudentCode.CAMERA_RGB) {
			    	if (studentCode.useCameraGUI)
			    		buttonView.setVisibility(View.VISIBLE);
			    };

			    
			    if((studentCode.useSensors & StudentCode.TIME_SYNC) == StudentCode.TIME_SYNC)
			    	synchronizedTime.Start();
			    
			    studentCode.start_up(this);
		        lock();
			    studentCode.start();
		        unlock();
			    
				active = true;

//				if(camera != null)
//					camera.startPreview();

				if(mLocationManager != null)
				    mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 0, this);       	
 
				SendCurrentSensorValues();
			       
				if(studentCode.loggingOn)
				{ 

			        String logName = new String(Environment.getExternalStorageDirectory() + "/sensorlog"+ 
							new SimpleDateFormat("yyyyMMddHHmm").format(new Date()) + ".csv");
					try {
						logFile = new BufferedOutputStream(new FileOutputStream(logName), 65536*16);
						String s = "C;"+System.currentTimeMillis()+";"+System.nanoTime()+"\n";
						logFile.write(s.getBytes());
					} catch (FileNotFoundException e) {
						e.printStackTrace();
					} catch (IOException e) {
						e.printStackTrace();
					}
				}	

				if((studentCode.useSensors & StudentCode.SOUND_IN) == StudentCode.SOUND_IN)
				{
					t1 = new Thread(new Runnable() {
					    synchronized public void run() {
					    	record();
					      }     
					    });
					t1.start();
				}return true;
			}else{
				item.setTitle("RX");
				active = false;

			    if((studentCode.useSensors & StudentCode.CAMERA) == StudentCode.CAMERA || (studentCode.useSensors & StudentCode.CAMERA_RGB) == StudentCode.CAMERA_RGB)
			    {
			    	buttonView.setVisibility(View.INVISIBLE);
					if(cameraState == CameraState.PLAYING && replayFile != null)
					{
						cameraState = CameraState.IDLE;
						try {
							replayFile.close();
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						replayFile = null;
					} 
					if(cameraState == CameraState.RECORDING && camera != null)
					{
						cameraState = CameraState.STARTED;
						if(recordingFile!=null)
						{
							try {
								recordingFile.flush();
								recordingFile.close();
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							recordingFile = null;
						}
					}
					if(cameraState == CameraState.STARTED && camera != null)
					{
						cameraState = CameraState.IDLE;
						if (studentCode.useAutoFocus)
							camera.cancelAutoFocus();
						camera.stopPreview();
					}
			    }
				studentCode.ips.clear();
				
//				if(camera != null)
//					camera.stopPreview();
				
				if(mLocationManager != null)
			       mLocationManager.removeUpdates(this);
			       

			    if((studentCode.useSensors & StudentCode.TIME_SYNC) == StudentCode.TIME_SYNC)
			    	synchronizedTime.Stop();
				
		        lock();
			    studentCode.stop();
		        unlock();
			   
		     //   studentCode.open_text_file();
		        
				if(studentCode.loggingOn)
				{

			        synchronized (this) 
			        {
				    	if(logFile != null)
					       try {
								logFile.flush();
								logFile.close();
								logFile = null;
							} catch (IOException e) {
								e.printStackTrace();
							}
					}
				}			
			}
		}return true;
		case 2:{
        	System.exit(0);
        	break;}
        case 3:

        	final AlertDialog.Builder alert = new AlertDialog.Builder(this);
			alert.setTitle(studentCode.userInputStringTitle);
			alert.setMessage(studentCode.userInputStringMessage);
			
			// Set an EditText view to get user input 
			final EditText input = new EditText(this);
			alert.setView(input);
			
			alert.setPositiveButton("Ok", new DialogInterface.OnClickListener() 
			{public void onClick(DialogInterface dialog, int whichButton) 
			{  String value = (input.getText()).toString();
			   studentCode.stringFromUser(value);

			}
			});
			alert.setNegativeButton("Cancel", new DialogInterface.OnClickListener() 
			 {  public void onClick(DialogInterface dialog, int whichButton) {    
			  // Canceled.  
		      //available.release();
			 }});
			alert.show();					        	
			return true;
			
        
		case 1:
			if(!active)
			{
				item.setTitle("Stop");
				studentCode.init(0);

				
			    if((studentCode.useSensors & StudentCode.CAMERA) == StudentCode.CAMERA || (studentCode.useSensors & StudentCode.CAMERA_RGB) == StudentCode.CAMERA_RGB) {
			    	if (studentCode.useCameraGUI)
			    		buttonView.setVisibility(View.VISIBLE);
			    };

			    
			    if((studentCode.useSensors & StudentCode.TIME_SYNC) == StudentCode.TIME_SYNC)
			    	synchronizedTime.Start();
			    
			    studentCode.start_up(this);
		        lock();
			    studentCode.start();
		        unlock();
			    
				active = true;

//				if(camera != null)
//					camera.startPreview();

				if(mLocationManager != null)
				    mLocationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 1000, 0, this);       	
 
				SendCurrentSensorValues();
			       
				if(studentCode.loggingOn)
				{ 

			        String logName = new String(Environment.getExternalStorageDirectory() + "/sensorlog"+ 
							new SimpleDateFormat("yyyyMMddHHmm").format(new Date()) + ".csv");
					try {
						logFile = new BufferedOutputStream(new FileOutputStream(logName), 65536*16);
						String s = "C;"+System.currentTimeMillis()+";"+System.nanoTime()+"\n";
						logFile.write(s.getBytes());
					} catch (FileNotFoundException e) {
						e.printStackTrace();
					} catch (IOException e) {
						e.printStackTrace();
					}
				}	

				if((studentCode.useSensors & StudentCode.SOUND_IN) == StudentCode.SOUND_IN)
				{
					t1 = new Thread(new Runnable() {
					    synchronized public void run() {
					    	record();
					      }     
					    });
					t1.start();
				}
			}else{
				item.setTitle("TX");
				active = false;

			    if((studentCode.useSensors & StudentCode.CAMERA) == StudentCode.CAMERA || (studentCode.useSensors & StudentCode.CAMERA_RGB) == StudentCode.CAMERA_RGB)
			    {
			    	buttonView.setVisibility(View.INVISIBLE);
					if(cameraState == CameraState.PLAYING && replayFile != null)
					{
						cameraState = CameraState.IDLE;
						try {
							replayFile.close();
						} catch (IOException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						replayFile = null;
					} 
					if(cameraState == CameraState.RECORDING && camera != null)
					{
						cameraState = CameraState.STARTED;
						if(recordingFile!=null)
						{
							try {
								recordingFile.flush();
								recordingFile.close();
							} catch (IOException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							recordingFile = null;
						}
					}
					if(cameraState == CameraState.STARTED && camera != null)
					{
						cameraState = CameraState.IDLE;
						if (studentCode.useAutoFocus)
							camera.cancelAutoFocus();
						camera.stopPreview();
					}
			    }
				studentCode.ips.clear();
				
//				if(camera != null)
//					camera.stopPreview();
				
				if(mLocationManager != null)
			       mLocationManager.removeUpdates(this);
			       

			    if((studentCode.useSensors & StudentCode.TIME_SYNC) == StudentCode.TIME_SYNC)
			    	synchronizedTime.Stop();
				
		        lock();
			    studentCode.stop();
		        unlock();
			   
				if(studentCode.loggingOn)
				{

			        synchronized (this) 
			        {
				    	if(logFile != null)
					       try {
								logFile.flush();
								logFile.close();
								logFile = null;
							} catch (IOException e) {
								e.printStackTrace();
							}
					}
				}			
			}
		
			
			return true;
		}
		return false;
	}
	
	long receiveTime = 0;
	long playTime = 0;
	double currentBufferStartRecordTime = 0;
	long startBufferStartRecordTime = 0;
	long startPlayTime = 0;
	long playSampleCounter = 0;
	long recordSampleCounter = 0;
	boolean getNextBuf = false;
	
	static String recStart = "S;";
	static String separator = ";";
	static String eol = "\n";
	void record()
	{
       	recordBufferSize = AudioRecord.getMinBufferSize(studentCode.sampleRate, AudioFormat.CHANNEL_CONFIGURATION_MONO, AudioFormat.ENCODING_PCM_16BIT);
       	recorder = new AudioRecord(MediaRecorder.AudioSource.MIC, studentCode.sampleRate,  AudioFormat.CHANNEL_CONFIGURATION_MONO, AudioFormat.ENCODING_PCM_16BIT, recordBufferSize*recordBuffers);
        recorder.setRecordPositionUpdateListener(this);
  
 		short buffer[] = new short[recordBufferSize];
        recorder.setNotificationMarkerPosition(recordBufferSize/2);
        recorder.setPositionNotificationPeriod(recordBufferSize/2);       
        recorder.startRecording();
        recordSampleCounter = 0;
        
       
        while (active) 
        {
           int rb = recorder.read(buffer, 0, recordBufferSize);
           if(rb<=0) // Error
        	   continue;
           long currentBufferTime =  startBufferStartRecordTime + 1000000L*recordSampleCounter/studentCode.sampleRate;
           recordSampleCounter += rb;

			if ((studentCode.loggingOn) & (studentCode.logSound)) 
			{
				String s = 	null;
				s = recStart+currentBufferTime+separator+rb+separator+Arrays.toString(buffer)+"\n";
				try {
					if(logFile != null)
						logFile.write(s.getBytes(),0,s.length());
				} catch (IOException e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}
			}
			
	        lock();
            studentCode.sound_in(currentBufferTime, buffer, rb);
	        unlock();
             	
        }
        
        recorder.stop();
        recorder = null;
  	}
	//@Override
	public boolean onTouchEvent(MotionEvent event) {
		if(event.getAction() == MotionEvent.ACTION_DOWN)
		{
	        lock();
	        studentCode.screen_touched(event.getX(),event.getY());
	        unlock();
		}
		
		return super.onTouchEvent(event);
	}
	//@Override
	public void onMarkerReached(AudioRecord recorder) {
		
       startBufferStartRecordTime = (long)(synchronizedTime.nowNetworkTimeNanos()*1000000L);
       startBufferStartRecordTime -= 1000000L*recordBufferSize/studentCode.sampleRate/2; 
       
    }
	//@Override
	boolean middleBuffer = true;
	public void onPeriodicNotification(AudioRecord recorder) {
       currentBufferStartRecordTime = synchronizedTime.nowNetworkTimeNanos(); //System.currentTimeMillis();//synchronizedTime.correctedTimeNanos() - 1000000000/sampleRate*128;
 	}
	//@Override
	public void onMarkerReached(AudioTrack track) {
        startPlayTime = System.currentTimeMillis();//synchronizedTime.correctedTimeNanos() - 1000000000/sampleRate*128;
	}
	//@Override
	public void onPeriodicNotification(AudioTrack track) {
	}
	public void onAccuracyChanged(Sensor sensor, int accuracy) {
	}
	
	float[] accelerometer_values = null;
	float[] gyroscope_values = null;
	float[] magnetic_field_values = null;
	float[] light_values = null;
	float[] proximity_values = null;
	long last_time_stamp = 0;
	
	void SendCurrentSensorValues()
	{
        lock();
		if(accelerometer_values!=null)
			studentCode.accelerometer(last_time_stamp, accelerometer_values[0], accelerometer_values[1], accelerometer_values[2]);
		if(gyroscope_values!=null)
			studentCode.gyroscope(last_time_stamp, gyroscope_values[0], gyroscope_values[1], gyroscope_values[2]);
		if(magnetic_field_values!=null)
			studentCode.magnetic_field(last_time_stamp, magnetic_field_values[0], magnetic_field_values[1], magnetic_field_values[2]);
		if(light_values!=null)
			studentCode.light(last_time_stamp, light_values[0]);
		if(proximity_values!=null)
			studentCode.proximity(last_time_stamp, proximity_values[0]);
        unlock();
	}
	      
	public void onSensorChanged(SensorEvent event) {
		String s = 	null;
		last_time_stamp = event.timestamp;
        lock();
		switch (event.sensor.getType()){
		case Sensor.TYPE_ACCELEROMETER:
    		s = "A;"+event.timestamp +";"+ event.values[0] +";"+ event.values[1] +";"+ event.values[2]+"\n";
    		accelerometer_values = event.values;
    		if(active)
    			studentCode.accelerometer(event.timestamp, accelerometer_values[0], accelerometer_values[1], accelerometer_values[2]);
			break;
		case Sensor.TYPE_GYROSCOPE:
    		s = "Y;"+event.timestamp +";"+ event.values[0] +";"+ event.values[1] +";"+ event.values[2]+"\n";
    		gyroscope_values = event.values;
    		if(active)
    			studentCode.gyroscope(event.timestamp, gyroscope_values[0], gyroscope_values[1], gyroscope_values[2]);
			break;
			case Sensor.TYPE_MAGNETIC_FIELD:
	    		s = "M;"+event.timestamp +";"+ event.values[0] +";"+ event.values[1] +";"+ event.values[2]+"\n";
	    		magnetic_field_values = event.values;
	    		if(active)
	    			studentCode.magnetic_field(event.timestamp, magnetic_field_values[0], magnetic_field_values[1], magnetic_field_values[2]);
				break;
			case Sensor.TYPE_LIGHT:
	    		s = "L;"+event.timestamp +";"+ event.values[0]+"\n";
	    		light_values = event.values;
	    		if(active)
	    			studentCode.light(event.timestamp, light_values[0]);
				break;
			case Sensor.TYPE_PROXIMITY:
		   		s = "P;"+event.timestamp +";"+ event.values[0]+"\n";
		   		proximity_values = event.values;
	    		if(active)
	    			studentCode.proximity(event.timestamp, proximity_values[0]);
				break;
			}
	        unlock();
			if(studentCode.loggingOn)
				try {
			    	if(logFile != null && s != null)
			    		logFile.write(s.getBytes(),0,s.length());
				} catch (IOException e) {
					e.printStackTrace();
				}
		}
	
	static CameraPreviewHandler conversionWrapper = new CameraPreviewHandler();
	public void onPreviewFrame(byte[] data, Camera camera) {
		Camera.Parameters p = camera.getParameters();
		Size s = p.getPreviewSize();
        lock();
        if((studentCode.useSensors & StudentCode.CAMERA_RGB) == StudentCode.CAMERA_RGB)
        {
        	byte[] rgbData = new byte[s.width*s.height*3];
        	conversionWrapper.yuv4202rgb(data, s.width, s.height, 0, rgbData);   
        	//int rgbData[] = convertYUV420_NV21toRGB8888(data, s.width, s.height);
        	studentCode.camera_image_rgb(rgbData, s.width, s.height);
        	if(recordingFile != null)
				try {
					recordingFile.write(s.width/256);
					recordingFile.write(s.width%256);
					recordingFile.write(s.height/256);
					recordingFile.write(s.height%256);
					recordingFile.write(rgbData);
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
        }
        else
        {
     		studentCode.camera_image(data, s.width, s.height);
        	if(recordingFile != null)
				try {
					recordingFile.write(s.width/256);
					recordingFile.write(s.width%256);
					recordingFile.write(s.height/256);
					recordingFile.write(s.height%256);
					recordingFile.write(data,0,s.width*s.height);
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
        };

	    unlock();
	}
	public void onLocationChanged(Location location) {
        lock();
		studentCode.gps(location.getTime(), location.getLatitude(), location.getLongitude(), location.getAltitude(), location.getAccuracy());
        unlock();
		String s = "G;"+location.getTime()+";"+location.getLatitude()+":"+location.getLongitude()+":"+location.getAltitude()+":"+location.getAccuracy()+"\n";
		if(studentCode.loggingOn)
			try {
		    	if(logFile != null && s != null)
		    		logFile.write(s.getBytes(),0,s.length());
			} catch (IOException e) {
				e.printStackTrace(); 
			}
 	}
	
	public byte[] read_data_from_file(String filename) {
		FileInputStream dataFile;
		File dir = new File(Environment.getExternalStorageDirectory().getPath());
		String filename_with_path = new String(dir+"/"+filename);
		
		byte[] dataBuffer=null;
		
		try {
			File file = new File(filename_with_path);
			long fileLength = file.length();
			dataBuffer = new byte[(int) fileLength];
			dataFile = new FileInputStream(file);
			dataFile.read(dataBuffer);
			dataFile.close();
		} catch (IOException e) {
			e.printStackTrace();
		};
		
		return dataBuffer;
	}

	
	public byte[] read_rgb_frame_from_file(int image_number, String filename) {
		BufferedInputStream loadFile;
		
		int width, height;
		
		File dir = new File(Environment.getExternalStorageDirectory().getPath()+"/recordings/");
		String filename_with_path = new String(dir+"/"+filename);
		
		byte[] frame=null;
		
		try {
			loadFile = new BufferedInputStream(new FileInputStream(filename_with_path));
			for (int i1=0;i1<image_number;i1++) {
				width =  loadFile.read()*256+loadFile.read();
				height = loadFile.read()*256+loadFile.read();
				loadFile.skip(width*height*3);
			};
			width= loadFile.read()*256+loadFile.read();
			height=loadFile.read()*256+loadFile.read();
			frame = new byte[width*height*3];
			loadFile.read(frame);
			loadFile.close();
		} catch (IOException e) {
			e.printStackTrace();
		};
		
		return frame;
	};
	
	public int read_rgb_frame_height_from_file(int image_number, String filename) {
		BufferedInputStream loadFile;
		
		int width=0, height=0;

		File dir = new File(Environment.getExternalStorageDirectory().getPath()+"/recordings/");
		String filename_with_path = new String(dir+"/"+filename);
		
		byte[] frame=null;
		
		try {
			loadFile = new BufferedInputStream(new FileInputStream(filename_with_path));
			for (int i1=0;i1<image_number;i1++) {
				width =  loadFile.read()*256+loadFile.read();
				height = loadFile.read()*256+loadFile.read();
				loadFile.skip(width*height*3);
			};
			width= loadFile.read()*256+loadFile.read();
			height=loadFile.read()*256+loadFile.read();
			loadFile.close();
		} catch (IOException e) {
			e.printStackTrace();
		};
		
		return height;
	};
	
	public int read_rgb_frame_width_from_file(int image_number, String filename) {
		BufferedInputStream loadFile;
		
		int width=0, height=0;
		
		File dir = new File(Environment.getExternalStorageDirectory().getPath()+"/recordings/");
		String filename_with_path = new String(dir+"/"+filename);
		
		byte[] frame=null;
		
		try {
			loadFile = new BufferedInputStream(new FileInputStream(filename_with_path));
			for (int i1=0;i1<image_number;i1++) {
				width =  loadFile.read()*256+loadFile.read();
				height = loadFile.read()*256+loadFile.read();
				loadFile.skip(width*height*3);
			};
			width= loadFile.read()*256+loadFile.read();
			loadFile.close();
		} catch (IOException e) {
			e.printStackTrace();
		};
		
		return width;
	};
	
	
	public void save_rgb_frame_on_file(String filename,byte[] frame,int width,int height,boolean append) {				
		BufferedOutputStream saveFile;
		File dir = new File(Environment.getExternalStorageDirectory().getPath()+"/recordings/");
		String filename_with_path = new String(dir+"/"+filename);
		
		try {
			saveFile = new BufferedOutputStream(new FileOutputStream(filename_with_path,append));
			saveFile.write(width/256);
			saveFile.write(width%256);
			saveFile.write(height/256);
			saveFile.write(height%256);
			saveFile.write(frame);
			saveFile.close();
		} catch (IOException e) {
			e.printStackTrace();
		};
	}
	
	public void write_string_on_logfile(String s) {
		s="U;"+s;
		if(studentCode.loggingOn)
			try {
		    	if(logFile != null && s != null)
		    		logFile.write(s.getBytes(),0,s.length());
			} catch (IOException e) {
				e.printStackTrace(); 
			}		
	}
	
	public void onProviderDisabled(String provider) {
	}
	public void onProviderEnabled(String provider) {
	}
	public void onStatusChanged(String provider, int status, Bundle extras) {
	}


	
	/**
	 * Converts YUV420 NV21 to RGB8888
	 * 
	 * @param data byte array on YUV420 NV21 format.
	 * @param width pixels width
	 * @param height pixels height
	 * @return a RGB8888 pixels int array. Where each int is a pixels ARGB. 
	 */
	public static int[] convertYUV420_NV21toRGB8888(byte [] data, int width, int height) {
	    int size = width*height;
	    int offset = size;
	    int[] pixels = new int[size];
	    int u, v, y1, y2, y3, y4;

	    // i percorre os Y and the final pixels
	    // k percorre os pixles U e V
	    for(int i=0, k=0; i < size; i+=2, k+=2) {
	        y1 = data[i  ]&0xff;
	        y2 = data[i+1]&0xff;
	        y3 = data[width+i  ]&0xff;
	        y4 = data[width+i+1]&0xff;

	        u = data[offset+k  ]&0xff;
	        v = data[offset+k+1]&0xff;
	        u = u-128;
	        v = v-128;

	        pixels[i  ] = convertYUVtoRGB(y1, u, v);
	        pixels[i+1] = convertYUVtoRGB(y2, u, v);
	        pixels[width+i  ] = convertYUVtoRGB(y3, u, v);
	        pixels[width+i+1] = convertYUVtoRGB(y4, u, v);

	        if (i!=0 && (i+2)%width==0)
	            i+=width;
	    }

	    return pixels;
	}

	private static int convertYUVtoRGB(int y, int u, int v) {
	    int r,g,b;

	    r = y + (int)1.402f*v;
	    g = y - (int)(0.344f*u +0.714f*v);
	    b = y + (int)1.772f*u;
	    r = r>255? 255 : r<0 ? 0 : r;
	    g = g>255? 255 : g<0 ? 0 : g;
	    b = b>255? 255 : b<0 ? 0 : b;
	    return 0xff000000 | (b<<16) | (g<<8) | r;
	}
	
	int CHOOSE_FILE_REQUESTCODE = 3645;
	public void openFile() {

        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setType("file/*"); // Eller byt till "*/*" om det inte fungerar
        intent.addCategory(Intent.CATEGORY_OPENABLE);

        // special intent for Samsung file manager
        Intent sIntent = new Intent("com.sec.android.app.myfiles.PICK_DATA");
         // if you want any file type, you can skip next line 
        //sIntent.putExtra("CONTENT_TYPE", minmeType); 
        sIntent.addCategory(Intent.CATEGORY_DEFAULT);

        Intent chooserIntent;
        if (getPackageManager().resolveActivity(sIntent, 0) != null){
            // it is device with samsung file manager
            chooserIntent = Intent.createChooser(sIntent, "Open file");
            chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, new Intent[] { intent});
        }
        else {
            chooserIntent = Intent.createChooser(intent, "Open file");
        }

        try {
            startActivityForResult(chooserIntent, CHOOSE_FILE_REQUESTCODE);
        } catch (android.content.ActivityNotFoundException ex) {
            //Toast.makeText(getApplicationContext(), "No suitable File Manager was found.", Toast.LENGTH_SHORT).show();
        }
	}
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {

	    if (requestCode==CHOOSE_FILE_REQUESTCODE)
	    {
	        String Fpath = data.getDataString();
	        String stringParts[] = Fpath.split("/");
	        String filename=stringParts[stringParts.length-1];
	        studentCode.stringFromBrowseForFile(filename);
	        // do something...
	    }
	 super.onActivityResult(requestCode, resultCode, data);

	}
	
	public void open_text_file(final String filename){ 
		

	
//		runOnUiThread(new Runnable() {
//            @Override
//            public void run() {
        		AlertDialog.Builder builder = new AlertDialog.Builder(this);
        		builder.setMessage("You received"+filename+". Do you want to open it?")
        		       .setCancelable(false)
        		       .setPositiveButton("OK", new DialogInterface.OnClickListener() {
        		           public void onClick(DialogInterface dialog, int id) {
        		        	   MimeTypeMap mime = MimeTypeMap.getSingleton();
        		        	   File file = new File(filename);
        		       		Intent intent = new Intent();
        		       		intent.setAction(android.content.Intent.ACTION_VIEW);
        		       		String ext=filename.substring(filename.lastIndexOf(".") + 1,filename.lastIndexOf(".") + 4);
        		       		
        	                String type = mime.getMimeTypeFromExtension(ext);
        	               
        		       		intent.setDataAndType(Uri.fromFile(file), type);
        		       		//intent.addCategory(Intent.CATEGORY_OPENABLE);
        		       		//intent.setData(Uri.fromFile(file));
        		       		startActivity(intent); 
        		           }
        		       })
        		       .setNegativeButton("Cancel",new DialogInterface.OnClickListener() {
        		           public void onClick(DialogInterface dialog, int id) {
        		        	  dialog.cancel();
        		           }
        		       });
        		AlertDialog alert = builder.create();
        		alert.show();
//            }
//        });
//		  File file = new File(filename);
//     		Intent intent = new Intent();
//     		intent.setAction(android.content.Intent.ACTION_VIEW);
//     		intent.setDataAndType(Uri.fromFile(file), "*/*");
//     		//intent.setData(Uri.fromFile(file));
//     		startActivity(intent);
		
		
		
//		File videoFile2Play = new File("/sdcard/nice_movie.mpeg");
//		Intent i = new Intent();
//		i.setAction(android.content.Intent.ACTION_VIEW);
//		i.setDataAndType(Uri.fromFile(videoFile2Play), "video/mpeg");
//		startActivity(i);
//		Intent intent = new Intent();
//		intent.setAction(android.content.Intent.ACTION_VIEW);
//		File file = new File("/sdcard/test.mp3");
//		intent.setDataAndType(Uri.fromFile(file), "audio/*");
//		startActivity(intent); 
		
		
		
	}
	


};

