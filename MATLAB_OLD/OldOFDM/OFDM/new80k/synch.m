function [t_samp t_end]= synch(r, mod_ts)

threshold=50; %define amplitude threshold to start  -> change accordingly.

% Loop to identify sample where received sequence is initialized
for(k=1:length(r))
    if(r(k)>threshold)
        k_index=k;
        break
    end
end

%margin=1e6;
[r_yts t]=xcorr(r(k_index:length(r)),mod_ts);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation
subplot(411)
stem(abs(r_yts(offset-10:offset+10))); title('Modulo of cross-correlation for synchronization'); xlabel('lag'); ylabel('Amplitude')

t_samp = k_index + (offset - (length(r_yts)+1)/2);%only positive lags.


for(k=1:length(r))
    if(r(end-k)>threshold)
        k_index=k;
        break
    end
end

margin =5000;
t_end = length(r) - k_index  + margin;
end
