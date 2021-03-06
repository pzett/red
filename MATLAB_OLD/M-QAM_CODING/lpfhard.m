function Hd = lpfhard(fc)
%LPFHARD Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 8.2 and the DSP System Toolbox 8.5.
% Generated on: 02-May-2014 17:38:30

% FIR Window Lowpass filter designed using the FIR1 function.

% All frequency values are in Hz.
Fs = 44100;  % Sampling Frequency

N     = 150;       % Order
Fc    = fc;     % Cutoff Frequency
flag  = 'scale';  % Sampling Flag
Alpha = 2.5;      % Window Parameter

% Create the window vector for the design algorithm.
win = gausswin(N+1, Alpha);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
Hd = dfilt.dffir(b);

% [EOF]
