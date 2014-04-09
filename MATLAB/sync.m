function [ k_start ] = sync(r,tsequence)

threshold=100; %define amplitude threshold to start  -> change accordingly.

% Modulate training sequence
bit_stream = tsequence; %merge the bits together

t = 0 : 1/fs : Tb-1/fs;%time for one bit
FSK_signal = []; %Signal to transmit
for ii = 1:length(bit_stream) 
    FSK_signal = [FSK_signal (bit_stream(ii)==1)*cos(2*pi*f1*t)+...
                             (bit_stream(ii)==0)*cos(2*pi*f2*t)    ];
end



%% Loop to identify sample where received sequence is initialized
for(k=1:length(r))
    if(r(k)>threshold)
        k_index=k;
        break
    end
end

%% verify where signal starts
block_length=gb_length*Tb*fs+length(mod_tsequence) %block to be analyzed 

%%apply cross correlation between received sequence and modulated tsequence
[r_yts t]=xcorr(r(k_index:k_index+block_length),mod_tsequence);

stem(abs(r_yts(ceil(length(r_yts)/2):end)));

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

k_index = k_index + (offset - (length(r_yts)+1)/2);%only positive lags. 


%Move index to the end of training seq. where bits containing length begin
k_start = k_index + length(mod_tsequence);


end

