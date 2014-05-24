function [ decoded ] =dem_OFDM(r,FS,S,P,Nc,high,fs,asym,win); 
%Author : Red Group - Francisco Rosario (frosario@kth.se)
%Demodulate OFDM symbols
 if(mod(length(r), S+P+FS) ~= 0 )
        r = [r  zeros(1,FS+S+P-mod(length(r), S+P+FS))]; %fill with zeros for reshaping purposes
    end
    
    if(asym)
        decoded = demodulate_OFDM_asym(r,FS,S,P,Nc,high,win);       
    else
        decoded = demodulate_OFDM(r,FS,S,P,Nc);
    end

end

