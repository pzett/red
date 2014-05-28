close all;
clear;
clc;
fs=44100;
Tmax=15;  % duration of signal
Fmax=22050;
t=0:1/(fs):Tmax; %sampling time
f0=1;      %initial frequency
f1=Fmax/2;   %half the maximum frequency
t1=Tmax/2; %time in wich the chirp is in half the maximum frq

y=0.999*chirp(t,f0,t1,f1);  %generate sweeping sinusoid}

tic %begin taking time
soundsc(y,fs);  %play sound
wavwrite(y, fs, 'test_signal.dat');
create_file_of_shorts('test_signal.dat',y*2^15-1)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
 while toc<Tmax
 %take the time
 end
 toc;
 disp('Finished');

figure; %plot transmited sound  
%pwelch(y)
% Set axes appropriately
[Ryy,f]=plotspectrum(y);
plot(f*fs/1000,Ryy,'k','LineStyle','-','LineWidth', 1.5);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
title('PSD input');
axis([0 22.1 min(Ryy-3) max(Ryy+3)]);
grid on;
