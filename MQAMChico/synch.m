function [t_samp ref]= synch(r, mod_ts)

% threshold=0.5; %define amplitude threshold to start  -> change accordingly.
% 
% % Loop to identify sample where received sequence is initialized
% for(k=1:length(r))
%     if(r(k)>threshold)
%         k_index=k;
%         break
%     end
% end
k_index=1;
[r_yts t]=xcorr(r,mod_ts);
stem(r_yts)
[peak,offset]=max(abs(r_yts)); %find peak of cross correlation

t_samp = k_index + (offset - (length(r_yts)+1)/2);%only positive lags.

ref=sum(ldivide(r(t_samp:t_samp+length(mod_ts)-1),mod_ts))/length(mod_ts);
end
