%% MODULATION


fs=44100; %Sampling frequency

% Frequency component for bit 1
f1 = 2500+2*fs/88; 
% Frequency component for bit 0 
f2 = 2500;

Tb=88/fs; %Bit period

ts_length=20; %length of training sequence
tsequence=round(rand(1,ts_length)); %generate tsequence
Nb=1000; %Number of bits to transmit
data = round(rand(1,Nb)); % Generate bits randomly
bit_stream = [tsequence data]; %merge the bits together




t = 0 : 1/fs : Tb-1/fs;%time for one bit
FSK_signal = []; %Signal to transmit

for ii = 1:length(bit_stream)
    
    FSK_signal = [FSK_signal (bit_stream(ii)==1)*cos(2*pi*f1*t)+...
                             (bit_stream(ii)==0)*cos(2*pi*f2*t)    ];
                         
end

r = [zeros(1,10^3) FSK_signal];







%% DEMODULATION

%modulate training sequence to verify cross correlation
modu_ts=[];
for ii = 1:length(tsequence)
    
    modu_ts = [modu_ts (tsequence(ii)==1)*cos(2*pi*f1*t)+ ...
                             (tsequence(ii)==0)*cos(2*pi*f2*t)];
           
end


% verify where signal starts
block_length=4096; %block to be analyzed
k_start=1;

r_yts=xcorr(r(k_start:k_start+4096),modu_ts);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_start = k_start + (offset - (length(r_yts)+1)/2); %only the positive ...
                                                    %matters

r=r(k_start:end);



%% Coherent demodulation with 2 correlators %

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





