package se.kth.android.StudentCode;

public class IIR {
	private int length;
	private double[] delayLine = new double[2];
	private double[] a;
	private double[] b;
	private int count = 0;

	IIR(double[] b_i,double[] a_i){
		length = a_i.length;
		a = a_i;
		b = b_i;

	}

	double[] getOutput(double[] input) {
		double[] output = new double[input.length];
		double[] aux = new double[2];
		for(int n = 0;n<input.length;n++){
			output[n] = b[0]*input[n]+delayLine[0];
			aux[0]=delayLine[0];
			aux[1]=delayLine[1];
			delayLine[0] =b[1]*input[n]+aux[1]-a[1]*output[n];
			delayLine[1] =b[2]*input[n]-a[2]*output[n];
		}
		return output;
	}
}



