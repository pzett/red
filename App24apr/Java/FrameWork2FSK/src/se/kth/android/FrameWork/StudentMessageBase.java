/* Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
* This software is provided  ’as is’. It is free to use for non-commercial purposes.
* For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
* for a license. For non-commercial use, we appreciate citations of our work,
* please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
* for how information on how to cite. */ 

package se.kth.android.FrameWork;

import java.lang.reflect.Field;

import se.kth.android.StudentCode.StudentMessage;

public class StudentMessageBase {

//	@SuppressWarnings("unchecked")
	public String toString()
	{
		String msgString = "";

		try {
			Class<?> msgClass = StudentMessage.class;
			if(!this.getClass().equals(msgClass))
				return msgString;
			
			Field[] msgFields = msgClass.getDeclaredFields();
			for(Field field : msgFields)
			{
				field.setAccessible(true);
				Class fieldClass  = field.getType();
				if(fieldClass.equals(Float.class))
					msgString += ((Float)field.get(this)).toString();
				else if(fieldClass.equals(Double.class))
					msgString += ((Double)field.get(this)).toString();
				else if(fieldClass.equals(Integer.class))
					msgString += ((Integer)field.get(this)).toString();
				else if(fieldClass.equals(Long.class))
					msgString += ((Long)field.get(this)).toString();
				else if(fieldClass.equals(Boolean.class))
					msgString += ((Boolean)field.get(this)).toString();
				else if(fieldClass.equals(Short.class))
						msgString += ((Short)field.get(this)).toString();

				
				msgString+=",";
			}
				
			
//		} catch (ClassNotFoundException e) {
//			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		}
		
		return msgString;
	}
	
	@SuppressWarnings("unchecked")
	public static StudentMessage fromString(String msgString)
	{
		StudentMessage msgObject = new StudentMessage();
		String[] strings = msgString.split(",");
		int strIndex = 0;
		try {
			Class<?> msgClass = StudentMessage.class;
				
			Field[] msgFields = msgClass.getDeclaredFields();
			for(Field field : msgFields)
			{
				field.setAccessible(true);
				Class fieldClass  = field.getType();
				if(fieldClass.equals(Float.class))
					field.set(msgObject,Float.valueOf(strings[strIndex]));
				else if(fieldClass.equals(Double.class))
					field.set(msgObject,Double.valueOf(strings[strIndex]));
				else if(fieldClass.equals(Integer.class))
					field.set(msgObject,Integer.valueOf(strings[strIndex]));
				else if(fieldClass.equals(Long.class))
					field.set(msgObject,Long.valueOf(strings[strIndex]));
				else if(fieldClass.equals(Boolean.class))
					field.set(msgObject,Boolean.valueOf(strings[strIndex]));
				else if(fieldClass.equals(Short.class))
					field.set(msgObject,Short.valueOf(strings[strIndex]));

				strIndex++;
			}
				
			
//		} catch (ClassNotFoundException e) {
//			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		}		
		
		return msgObject;
	}
}
