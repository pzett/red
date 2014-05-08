/**
	Copyright (C) 2009,2010  Tobias Domhan

    This file is part of AndOpenGLCam.

    AndObjViewer is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    AndObjViewer is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with AndObjViewer.  If not, see <http://www.gnu.org/licenses/>.
 
 */
package edu.dhbw.andar;


public class CameraPreviewHandler {
	static { 
	    System.loadLibrary( "yuv420sp2rgb" );	
	} 
	
	private native void yuv420sp2rgb(byte[] in, int width, int height, int textureSize, byte[] out);

	public void yuv4202rgb(byte[] in, int width, int height, int textureSize, byte[] out)
	{
		yuv420sp2rgb(in, width, height, textureSize, out);
	}
}
