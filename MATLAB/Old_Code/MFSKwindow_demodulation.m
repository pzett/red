function [decision, k_start] = MFSKwindow_demodulation(r,data,fs,f,Tb,gb_length,t,tsequence)

nr_samples_bit=floor(t*fs);
nr_samples_period=floor(Tb*fs);

M = length(f);

threshold=100; %define threshold to start detection
for(k=1:length(r))
    if(r(k)>threshold)
        k_start=k;
        break
    end
end

%start detecting -> detect training sequence
%modulate training sequence

modu_ts=[];
tx_temp=[];
tx_short=[];
tx_guard=zeros(1,floor(Tb*fs)-floor(t*fs));
pulse=[];
window=hann(nr_samples_bit);
delta=10;
for(k=1:log2(M):length(tsequence))
    
    b=[tsequence(k) tsequence(k+1)];
    b_d=bi2de(b,'left-msb');
    switch b_d
        case 0
            fn = [f(1)-delta f(1)+delta]*2/fs;
        case 2
            fn = [f(2)-delta f(2)+delta]*2/fs;
        case 3
            fn = [f(3)-delta f(3)+delta]*2/fs;
        case 1
            fn = [f(4)-delta f(4)+delta]*2/fs;
    end
    pulse=fir1(nr_samples_bit-1,fn,window);
    tx_temp = ones(1,nr_samples_bit);
    tx_short = tx_temp .* pulse;
    tx_temp = [tx_short tx_guard];
    modu_ts=[modu_ts tx_temp];
    pulse=0;
end

% verify where signal starts by using correlation
block_length=12000; %block to be analyzed

r_yts=xcorr(r(k_start:k_start+block_length),modu_ts);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation
(offset - (length(r_yts)+1)/2);
k_start = k_start + (offset - (length(r_yts)+1)/2); %only the positive part of the autocorrelation
                                                  %matters
r=r(k_start:end);

decision=goertzel2(f(1),f(2),f(3),f(4),fs,Tb*fs,r);

end

