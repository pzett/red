function [t_samp, ref]= synch(r, mod_ts,n_sym,plotting,offline_flag)

threshold=50; %define amplitude threshold to start  -> change accordingly.
  
 if(exist('offline_flag'))
    threshold=0.5; %for simulation
 end
% Loop to identify sample where received sequence is initialized
for(k=1:length(r))
    if(r(k)>threshold)
        k_index=k;
        break
    end
end

margin=1000;
[r_yts t]=xcorr(r(k_index:k_index+length(mod_ts)+n_sym*margin),mod_ts);

[peak,offset]=max(abs(r_yts)); %find peak of cross correlation
if(plotting) stem(abs(r_yts)); end

t_samp = k_index + (offset - (length(r_yts)+1)/2);%only positive lags.

ref=1;

%ref=sum(ldivide(r(t_samp:t_samp+length(mod_ts)-1),mod_ts))/length(mod_ts);
end
