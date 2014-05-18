function [ decoded ] =dem_OFDM(r,FS,S,P,Nc,high,fs,asym); 
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
 if(mod(length(r), S+P+FS) ~= 0 )
        r = [r  zeros(1,FS+S+P-mod(length(r), S+P+FS))]; %fill with zeros for reshaping purposes
    end
    
    if(asym)
        decoded = demodulate_OFDM_asym(r,FS,S,P,Nc,high);       
    else
        decoded = demodulate_OFDM(r,FS,S,P,Nc);
    end

end

