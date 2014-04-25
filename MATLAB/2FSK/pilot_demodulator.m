function [k_start length_of_data] = pilot_demodulator(r,tsequence,gb_length,Tb,fs,f1,f2,info_length)
%%PILOT_DEMODULATOR Uses the received signal and known training sequence to
%detect k_start which is the index where the data signal starts. Also decodes the bits in the pilot that
%identifies the number of bits in data (size of file in bits)
%%
mod_tsequence=FSK_modulation(tsequence,fs,f1,f2,Tb,0,[]);
threshold=100; %define amplitude threshold to start  -> change accordingly.
threshold=0.01;
%% Loop to identify sample where received sequence is initialized
for(k=1:length(r))
    if(r(k)>threshold)
        k_index=k;
        break
    end
end

%% verify where signal starts
block_length=gb_length*Tb*fs+length(mod_tsequence); %block to be analyzed 

%%apply cross correlation between received sequence and modulated tsequence
[r_yts t]=xcorr(r(k_index:k_index+block_length),mod_tsequence);

stem(abs(r_yts(ceil(length(r_yts)/2):end)));

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_index = k_index + (offset - (length(r_yts)+1)/2);%only positive lags. 


%Move index to the end of training seq. where bits containing length begin
k_index = k_index + length(mod_tsequence) - 1;


%% Decode length information
% info_length = d_length*Tb*fs; %samples containing length information
%  
% info_mod = r(k_index:k_index+info_length); %crop r
%  
% length_of_data_binary = goertzel(f1,f2,fs,Tb*fs,info_mod);%demodulate
% 
% length_of_data= bin2dec(int2str(length_of_data_binary));%convert to decimal

k_start = k_index + info_length; %return k_start where data begins

length_of_data=info_length;

end

