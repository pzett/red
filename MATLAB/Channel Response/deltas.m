close all;
clear;
clc;
fs=44100;
Tmax=5;  % duration of signal
T=1/fs;
t=0:T:Tmax; %sampling time
y=zeros(1,length(t));
t=0:1/(fs):Tmax; %sampling time
for k=1:1000:length(t)
y(k:k+10)=0.999;
end


tic %begin taking time
%soundsc(y,fs);  %play sound
wavwrite(y, fs, 'test_signal.dat');
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
