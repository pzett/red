close all;
clear;
clc;

%Initialize variables

fs=44100; %Sampling frequency

Tb=200/fs; %Bit period

Nb=1000;

tsequence=importdata('tsequence.mat');
data=importdata('data.mat');

% Define the two frequencies 
% Frequency component for bit 1
f1 = 2500+4*fs/200; 
% Frequency component for bit 0 
f2 = 2500;

t = 0 : 1/fs : Tb-1/fs;%time for one bit
names=list_sensor_log_files_on_sdcard;
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);
log_data=get_log_data_from_FrameWork(filename); 
r=extract_sound_from_log_data(log_data);

%%

%r=wavread('testsound.wav')
length(r)

threshold=100; %define threshold to start detection

for(k=1:length(r))
    if(r(k)>threshold)
        k_start=k;
        break
    end
end


%modulate training sequence to verify cross correlation
modu_ts=[];
for ii = 1:length(tsequence)
    
    modu_ts = [modu_ts (tsequence(ii)==1)*cos(2*pi*f1*t)+ ...
                             (tsequence(ii)==0)*cos(2*pi*f2*t)];
           
end


% verify where signal starts
block_length=4096; %block to be analyzed

r_yts=xcorr(r(k_start:k_start+4096),modu_ts);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_start = k_start + (offset - (length(r_yts)+1)/2); %only the positive ...
                                                    %matters

r=r(k_start:end);
r=r';
%%

decision = goertzel(f1,f2,fs,200,r);
sum(decision(1:length([tsequence data]))~=[tsequence data])




% errors=sum(decision~=[tsequence data])
% 
% decision=goertzel(f1,f2,fs,88,r);
% 
% sum(decision~=[tsequence data])
% 
% pause

%Coherent demodulation with 2 correlators %
% multiplier1 = cos(2*pi*f1*t);
% multiplier2 = -cos(2*pi*f2*t);
% 
% %for first symbol
% decision1(1)=trapz(r(1:fs*Tb).*multiplier1); %integrate
% decision2(1)=trapz(r(1:fs*Tb).*multiplier2); %integrate
% 
% 
% if(abs(decision1(1))>abs(decision2(1))) % compare
%     decision(1)=1;
% else
%     decision(1)=0;  
% end
% 
% 
% %for rest of symbols
% for(k=2:length([tsequence data]))  
%     
% decision1(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier1);
% decision2(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier2);
% if(abs(decision1(k))>abs(decision2(k)))
%     decision(k)=1;
% else
%     decision(k)=0;
%     
% end
% 
% end
% 
% disp('errors for coherent demodulation:')
% errors=sum(decision~=[tsequence data])
% 


%%% end of coherent demodulator

%%
% Non coherent demodulator -  correlator implementation


% multiplier1 = cos(2*pi*f1*t);
% multiplier2 = sin(2*pi*f1*t);
% multiplier3 = cos(2*pi*f2*t);
% multiplier4 = sin(2*pi*f2*t);
% 
% decision1(1)=trapz(r(1:fs*Tb).*multiplier1); %integrate
% decision2(1)=trapz(r(1:fs*Tb).*multiplier2); %integrate
% decision3(1)=trapz(r(1:fs*Tb).*multiplier3); %integrate
% decision4(1)=trapz(r(1:fs*Tb).*multiplier4); %integrate
% 
% l12=decision1(1).^2+decision2(1).^2;
% l22=decision3(1).^2+decision4(1).^2;
% 
% if(l12>l22)
%     decision(1)=1;
% else
%     decision(1)=0;
% end 
% 
% 
% %for rest of symbols
% for(k=2:length([tsequence data]))
%     decision1(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier1); %integrate
%     decision2(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier2); %integrate
%     decision3(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier3); %integrate
%     decision4(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier4); %integrate
%     
%     l12=decision1(k).^2+decision2(k).^2;
%     l22=decision3(k).^2+decision4(k).^2;
%     if(l12>l22)
%         decision(k)=1;
%     else
%         decision(k)=0;
%     end
%     
% end
% disp('errors for non-coherent demodulation (correlator):')
% errors=sum(decision~=[tsequence data])


%end %of non-coherent correlator demodulator





