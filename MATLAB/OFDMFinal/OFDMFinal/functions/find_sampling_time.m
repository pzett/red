function [ t_samp ] = find_sampling_time(asym,ts_length,margin,ro,fs,fc,FS,S,P,Nc,high,mconst_ts,t_end,t_samp,window);
% Author : Red Group - Francisco Rosario (frosario@kth.se)
% Find best sampling time by correlating with symbols. Suboptimal
% algorithm. May lead to errors if prefixes are too large. This errors are
% usually detected in the phase estimation and a warning is given.


max = 0;
vec_max = zeros(2*margin+1,1);
for(k=-margin:1:margin)% test different sampling times and find peak of crosscorrelation
    n_samp = t_samp + k;
    r=ro(n_samp:t_end); 
    t = 0: 1/fs : (length(r) - 1) / fs;
    r=exp(-1i*2*pi*fc*t).*r; % multiply with the exponential
    
    if(mod(length(r), S+P+FS) ~= 0 )
        r = [r  zeros(1,FS+S+P-mod(length(r), S+P+FS))]; %fill with zeros for reshaping purposes
    end
    
    if(asym)
        decoded = demodulate_OFDM_asym(r,FS,S,P,Nc,high,window);
    else
        decoded = demodulate_OFDM(r,FS,S,P,Nc);
    end
    
    max_sync=abs(transpose(decoded(1:ts_length))*mconst_ts'); % cross correlate
    
        
    if(max_sync > max); max = max_sync; best_margin = k; end
end

t_samp = t_samp + best_margin;

end

