function [k_start length_of_data] = pilot_demodulator(r,mod_tsequence,gb_length,Tb,fs,f1,f2 )
%PILOT_DEMODULATOR Uses the received signal and known training sequence to
%detect k_start which is the idex were the data signal starts. Also decodes the bits in the pilot that
% tells the number of bits in data

number_of_datalength_bits = 17;

threshold=100; %define threshold to start detection

for(k=1:length(r))
    if(r(k)>threshold)
        k_index=k
        break
    end
end

% verify where signal starts
block_length=gb_length*Tb*fs+length(mod_tsequence) %block to be analyzed

[r_yts t]=xcorr(r(k_index:k_index+block_length),mod_tsequence);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_index = k_index + (offset - (length(r_yts)+1)/2); %only the positive ..


% Move index to end of training sequence where info bits begin
k_index = k_index + length(mod_tsequence) - 1;


% Decode length information
 info_length = number_of_datalength_bits*Tb*fs;
 
 info_mod = r(k_index:k_index+info_length);
 
length_of_data_binary = goertzel(f1,f2,fs,Tb*fs,info_mod);

length_of_data = bin2dec(int2str(length_of_data_binary));

k_start = k_index + info_length;






end

