function [ ynew ] = get_audio( filename,L )
%UNTITLED16 Summary of this function goes here
%   Detailed explanation goes here
%'wants_some.wav'
[y, Fs, nbits] = wavread(filename);
fs = 44.1e3;
[P,Q] = rat(fs/Fs);
ynew = resample(y,P,Q);
ynew = [ynew; zeros(L-length(ynew),1)];
% ylow = audioplayer(y,Fs);


figure

ynew = ynew' / max(abs(ynew));
pwelch(ynew,[],[],[],44.1e3)
yhigh = audioplayer(ynew,44.1e3);
play(yhigh)
pause(3)
end

