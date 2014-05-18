function [t_samp t_end]= synch(r, mod_ts,fs,mod_signal)

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
% subplot(411)
% stem(abs(r_yts(offset-10:offset+10))); title('Modulo of cross-correlation for synchronization'); xlabel('lag'); ylabel('Amplitude')

t_samp = k_index + (offset - (length(r_yts)+1)/2);%only positive lags.


for(k=1:length(r))
    if(r(end-k)>threshold)
        k_index=k;
        break
    end
end

margin =5000;
t_end = length(r) - k_index  + margin;
fc=9000;
subplot(211)
hold on
pwelch(mod_signal,[],[],[],fs); title('PSD of transmitted signal');
line([fc fc], [-100 -40],'Color','r','LineWidth',1)
subplot(212)
hold on
pwelch(r,[],[],[],fs); title('PSD of received signal')
line([fc fc], [0 100],'Color','r','LineWidth',1)
end
