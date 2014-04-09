function [ decision, k_start ] = FSK_demodulation( r,data,fs,f1,f2,Tb,gb_length,ts_length,tsequence )

t = 0 : 1/fs : Tb-1/fs; %time for one bit

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

%Coherent demodulation with 2 correlators %
multiplier1 = cos(2*pi*f1*t);
multiplier2 = -cos(2*pi*f2*t);
length(r(1:fs*Tb))
multiplier1
%for first symbol
decision1(1)=trapz(r(1:round(fs*Tb)).*multiplier1); %integrate
decision2(1)=trapz(r(1:round(fs*Tb)).*multiplier2); %integrate


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




%% end of coherent demodulator



end

