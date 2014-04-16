/* Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
* This software is provided  ’as is’. It is free to use for non-commercial purposes.
* For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
* for a license. For non-commercial use, we appreciate citations of our work,
* please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
* for how information on how to cite. */ 

package se.kth.android.FrameWork;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

public class PlotView extends View {

    Paint green = new Paint();
    Paint red = new Paint();
    Paint yellow = new Paint();
    Paint orange = new Paint();
    Paint blue = new Paint();

    Bitmap mapBM = null;

    FrameWork fw=null;

	public PlotView(Context context, AttributeSet as)
    {
    	super(context,as);
        setFocusable(true);
        setFocusableInTouchMode(true);
        
 
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
    

	public long maxTime = Long.MIN_VALUE;
	public long minTime = Long.MAX_VALUE;
	public long maxOffset = Long.MIN_VALUE;
	public long minOffset = Long.MAX_VALUE;
   
    
    public void onDraw(Canvas canvas) {
    	if(mapBM == null)
    	   	mapBM = Bitmap.createBitmap(getMeasuredWidth(), getMeasuredHeight(), Bitmap.Config.RGB_565);

    	Canvas bmcanvas = new Canvas(mapBM);
    	bmcanvas.drawColor(Color.BLACK);
    	
    	fw.lock();
    	fw.studentCode.plot_data(bmcanvas, getWidth(), getHeight());
    	fw.unlock();
    	
    	int w = getMeasuredWidth();
    	int h = getMeasuredHeight();
    	if(fw != null && fw.synchronizedTime.ntpoffsets != null)
    	{
    		maxTime = Long.MIN_VALUE;
    		minTime = Long.MAX_VALUE;
    		maxOffset = Long.MIN_VALUE;
    		minOffset = Long.MAX_VALUE;
    		for(SynchronizedTime.NTPOffsets os : fw.synchronizedTime.ntpoffsets)
    		{
    			if(os != null)
    			{
	    			if(os.offset>maxOffset)
	    				maxOffset = os.offset;
	    			if(os.offset<minOffset)
	    				minOffset = os.offset;
	    			if(os.returnT>maxTime)
	    				maxTime = os.returnT;
	    			if(os.returnT<minTime)
	    				minTime = os.returnT;
    			}
    		}
    		float ys = (maxOffset-minOffset)/h;
    		float xs = (maxTime-minTime)/w;
    		if(ys>0&&xs>0)
    		for(SynchronizedTime.NTPOffsets os : fw.synchronizedTime.ntpoffsets)
    		{
    			if(os != null)
    			{
    				float x = (os.returnT-minTime)/xs;
    				float y = (os.offset-minOffset)/ys;
    				bmcanvas.drawCircle(x, y, 5, red);
    			}
    		}
    	}
    	/*
    	if(fw != null && fw.synchronizedTime.ntpoffsets != null)
    	{
    		int row = 0;
			double centerVal = fw.synchronizedTime.currOffset;
			centerVal = centerVal/(0x10000000);
			centerVal = centerVal/16;
			int c = getMeasuredWidth()/2;
			int lh = getMeasuredHeight()/10;
			bmcanvas.drawLine( (float)(c),  0, (float)(c), getMeasuredHeight(), yellow);
    		for(SynchronizedTime.NTPOffsets os : fw.synchronizedTime.ntpoffsets)
    		{
    			if(os != null)
    			{
    				int scale = 10000;
	       			double o = os.offset;
	    			o = o/(0x10000000);
	    			o = o/16;
	       			double d = os.delay;
	    			d = d/(0x10000000);
	    			d = d/16;
	    			float lb = (float)(c-(centerVal-o-d/2))*scale;
	    			lb +=1;
	    			bmcanvas.drawLine( (float)(c-(centerVal-o-d/2)*scale),  row*lh,  (float)(c-(centerVal-o-d/2)*scale), row*lh+lh, red);
	    			bmcanvas.drawLine( (float)(c-(centerVal-o+d/2)*scale),  row*lh,  (float)(c-(centerVal-o+d/2)*scale), row*lh+lh, red);
	    			bmcanvas.drawLine( (float)(c-(centerVal-o)*scale),  row*lh, (float)(c-(centerVal-o)*scale), row*lh+lh, green);
	    			row+=1;
    			}
    		}
    	}*/
    	canvas.drawBitmap(mapBM, 0, 0, red);
    }
}





