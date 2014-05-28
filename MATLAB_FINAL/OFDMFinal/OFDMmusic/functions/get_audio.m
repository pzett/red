function [ ynew ] = get_audio( filename,L )
%UNTITLED16 Summary of this function goes here
%   Detailed explanation goes here
%'wants_some.wav'
[y, Fs, nbits] = wavread(filename);
fs = 44.1e3;
[P,Q] = rat(fs/Fs);
ynew = resample(y(:,1),P,Q);
if(L > length(ynew))
ynew = [ynew; zeros(L-length(ynew),1)];
else
ynew = ynew(L/2:end);    
end
% ylow = audioplayer(y,Fs);
Hd = lpf(100,8000,2);
ynew = filter(Hd,ynew);

ynew = ynew' / max(abs(ynew));

yhigh = audioplayer(ynew,44.1e3);
play(yhigh)
ynew = ynew(1:L);
subplot(222)
pwelch(ynew,[],[],[],fs); title('Spectrum of LPFd music')
end

