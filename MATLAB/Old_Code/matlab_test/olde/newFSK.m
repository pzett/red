close all;
clear;
clc;

%Initialize variables

fs=44100; %Sampling frequency

Tb=88/fs; %Bit period

Nb=1000; %Number of bits to transmit

data = round(rand(1,Nb)); % Generate bits randomly
dlmwrite ('dataFSK.txt',data); %Save bits on a txt file

gb_length=10; %length of guard band
ts_length=20; %length of training sequence
guard=round(rand(1,gb_length)); %generate guard band
tsequence=round(rand(1,ts_length)); %generate tsequence
bit_stream = [guard tsequence data]; %merge the bits together

save('tsequence.mat','tsequence');

% Define the two frequencies 
% Frequency component for bit 1
f1 = 2500+2*fs/88; 
% Frequency component for bit 0 
f2 = 2500;

% Time for one bit
t = 0 : 1/fs : Tb-1/fs;

time = []; % complete time
FSK_signal = []; %Signal to transmit
 
t_tot=t; %auxiliary variable


%Modulation 

%Generate FSK_signal
for ii = 1:length(bit_stream)
    
    FSK_signal = [FSK_signal (bit_stream(ii)==1)*cos(2*pi*f1*t)+...
                             (bit_stream(ii)==0)*cos(2*pi*f2*t)    ];
   
    time=[time t_tot];
    t_tot=t_tot+Tb;
end


%Send signal through channel%

snr=50; %Define SNR in dB
y = awgn(FSK_signal,snr,'measured');


%Received signal
sigma2=0.02; %std deviation of noise

r=[sigma2.*randn(2000,1)' y ];%0*sigma2.*randn(2000,1)']; %merge with noise

threshold=0.5; %define threshold to start detection

for(k=1:length(r))
    if(r(k)>threshold)
        k_start=k;
        break
    end
end


%modulate training sequence to verify cross correlation
modu_ts=[];
for ii = 1:length(tsequence)
    
    modu_ts = [modu_ts (tsequence(ii)==1)*cos(2*pi*f1*t)+...
                             (tsequence(ii)==0)*cos(2*pi*f2*t)    ];
           
end


% verify where signal starts
block_length=4096; %block to be analyzed

r_yts=xcorr(r(k_start:k_start+4096),modu_ts);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_start = k_start + (offset - (length(r_yts)+1)/2); %only the positive ...
                                                    %matters

r=r(k_start:end);






%Coherent demodulation with 2 correlators %
multiplier1 = cos(2*pi*f1*t);
multiplier2 = -cos(2*pi*f2*t);

%for first symbol
decision1(1)=trapz(r(1:fs*Tb).*multiplier1); %integrate
decision2(1)=trapz(r(1:fs*Tb).*multiplier2); %integrate


if(abs(decision1(1))>abs(decision2(1))) % compare
    decision(1)=1;
else
    decision(1)=0;  
end


%for rest of symbols
for(k=2:length([tsequence data]))  
    
decision1(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier1);
decision2(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier2);
if(abs(decision1(k))>abs(decision2(k)))
    decision(k)=1;
else
    decision(k)=0;
    
end

end

disp('errors for coherent demodulation:')
errors=sum(decision~=[tsequence data])



%%% end of coherent demodulator


% Non coherent demodulator -  correlator implementation


multiplier1 = cos(2*pi*f1*t);
multiplier2 = sin(2*pi*f1*t);
multiplier3 = cos(2*pi*f2*t);
multiplier4 = sin(2*pi*f2*t);

decision1(1)=trapz(r(1:fs*Tb).*multiplier1); %integrate
decision2(1)=trapz(r(1:fs*Tb).*multiplier2); %integrate
decision3(1)=trapz(r(1:fs*Tb).*multiplier3); %integrate
decision4(1)=trapz(r(1:fs*Tb).*multiplier4); %integrate

l12=decision1(1).^2+decision2(1).^2;
l22=decision3(1).^2+decision4(1).^2;

if(l12>l22)
    decision(1)=1;
else
    decision(1)=0;
end 


%for rest of symbols
for(k=2:length([tsequence data]))
    decision1(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier1); %integrate
    decision2(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier2); %integrate
    decision3(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier3); %integrate
    decision4(k)=trapz(r(round((k-1)*fs*Tb+1):round(k*fs*Tb)).*multiplier4); %integrate
    
    l12=decision1(k).^2+decision2(k).^2;
    l22=decision3(k).^2+decision4(k).^2;
    if(l12>l22)
        decision(k)=1;
    else
        decision(k)=0;
    end
    
end
disp('errors for non-coherent demodulation (correlator):')
errors=sum(decision~=[tsequence data])

decision=goertzel(f1,f2,fs,88,r);

sum(decision~=[tsequence data])

wavwrite(FSK_signal, fs, 'testsound.wav');
copy_file_from_working_directory_to_sdcard( 'testsound.wav' );


%end of non-coherent correlator demodulator






% 
% % Non-coherent demodulator - Bandpass implementation
% 
% %Generate filters
% Nf=50; %order of filters
% hf1=BPFf1(f1,Nf);
% hf2=BPFf2(f2,Nf);
% 
% l1=filter(hf1,r);
% l2=filter(hf2,r);
% 
% 
% 
% pause
% %envelope detection
% 
% l1=2*l1.^2;
% l1=downsample(l1,4);
% l2=2*l2.^2;
% l2=downsample(l2,4)
% 
% hlpf=LPFfc5;
% 
% l1=sqrt(filter(hlpf,l1));
% l2=sqrt(filter(hlpf,l2));
% 
% pause
% 
% 
% 
% op1 = conv(r, cos(2*pi*f1*t)); % correlating with frequency 1
% op2 = conv(r, cos(2*pi*f2*t)); % correlating with frequency 2
% 
%         
% figure(3)
% periodogram(FSK_signal)
% decision= ( abs(op2((Tb+1/fs)*fs:Tb*fs:end)) < abs(op1((Tb+1/fs)*fs:Tb*fs:end)) );
% 
% 
% 
% hold on
% 
% %FSK Signal
% figure(1)
% subplot(3,1,2);
% plot(time,FSK_signal);
% xlabel('Time (bit period)');
% ylabel('Amplitude');
% title('FSK Signal with two Frequencies');
% axis([0 time(end) -1.5 1.5]);
% grid  on;
%  
%  % Plot the Original Digital Signal
% subplot(3,1,1);
% plot(time,Digital_signal,'r','LineWidth',2);
% xlabel('Time (bit period)');
% ylabel('Amplitude');
% title('Original Digital Signal');
% axis([0 time(end) -0.5 1.5]);
% grid on;
% 
%  % Plot the Received Digital Signal
% subplot(3,1,3);
% plot(time,Digital_signal,'g','LineWidth',2);
% xlabel('Time (bit period)');
% ylabel('Amplitude');
% title('Received Digital Signal');
% axis([0 time(end) -0.5 1.5]);
% grid on;
% sum(decision~=bit_stream)
% 
% figure(3)
% audioplayer(FSK_signal,fs)



