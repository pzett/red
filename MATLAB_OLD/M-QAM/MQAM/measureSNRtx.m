%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');
%Initialize variables
fs=44100; %Sampling frequency


f = 5000; % Transmitted frequency

T = 10; % Duration of signal in seconds

t = 0:1/fs:T/2;

sine = sin(2*pi*f*t);

mod_signal = [zeros(1,length(t)) sine zeros(1,1000)];

save('sine.mat','sine')
wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length)



