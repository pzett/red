clear all
close all
clc

fs = 44100;
f1 = 1/24*fs;
f2 = 4/24*fs;
Tb = 50/fs;

ts_length = 20;
data_length = 5120;
gb_length = 200;

tsequence = round(rand(1,ts_length));


[mod_pilot mod_tsequence] = pilot_modulator(tsequence,data_length,gb_length,Tb,fs,f1,f2);

r = [zeros(1,10000) mod_pilot zeros(1,10000)];

[k_start length_of_data] = pilot_demodulator(r,mod_tsequence,gb_length,Tb,fs,f1,f2)