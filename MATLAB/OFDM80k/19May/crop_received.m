function [ r ] =  crop_received(ro,g_eq,use_eq,use_hpf,ts_mod,asym);
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if(use_eq)
    r=peakEQ(ro,g_eq)'; % apply equalizer
    
    if(use_hpf)
        Hd = hpf; % generate high pass filter to filter low pass component of noise
        r = filter(Hd,r);
    end
else
    r=ro;
end


r=ro; %received samples
[t_samp_o, t_end]=synch(r,ts_mod);

r=r';
margin = 5;
t_samp = find_sampling_time(asym,ts_length,margin,r,fs,fc,FS,S,P,Nc,high,mconst_ts,t_end,t_samp_o);

r=r(t_samp:t_end);

end

