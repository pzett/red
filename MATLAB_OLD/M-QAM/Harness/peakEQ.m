function [ y,b,a ] = peakEQ( x,G0,F0)
%fdesign.parameq('F0,BW,BWp,Gref,G0,GBW,Gp',0.2732,0.15,0.03,0,8,3,5);
% F0 — Center Frequency
% BW — Bandwidth
% BWp — Passband Bandwidth
% Gref — Reference Gain (decibels)
% G0 — Center Frequency Gain (decibels)
% GBW — Gain at which Bandwidth (BW) is measured (decibels)
% Gp — Passband Gain (decibels)
% x -- x(n) discrete data input
% y -- y(n) discrete data output

if nargin>2; %Change the frequency
  F0=F0/22050; 
else
 F0=0.2732; %use predefined frequency (normalized)
end
%% Predefined parameters
BW=0.15;
BWp=0.03;
Gref=0;
GBW=3;
Gp=5;
%% Create filter
d=fdesign.parameq('F0,BW,BWp,Gref,G0,GBW,Gp',F0,BW,BWp,Gref,G0,GBW,Gp);
Hiir=design(d);
[b,a]=sos2tf(Hiir.sosMatrix); % They should be length 3

%       b0k +  b1k z^-1 +  b2k  z^-2
% H(z)= ----------------------------
%       1 +  a1k z^-1 +  a2k  z^-2

%% Write coefficients into file
fid=fopen('eqcoeffs.txt','w');
 for(k=1:length(b))
    fprintf(fid,'%1.8f\n',b(k));
 end
 for(k=1:length(a))
    fprintf(fid,'%1.8f\n',a(k));
 end
fclose(fid);

%% Filter sequence with direct form implementation
z = zeros(1,2);
Nx = length(x);

for n = 1:Nx
    y(n) = b(1)*x(n) + z(1);
    z_prev = z;
    z(1) = b(2)*x(n)+z_prev(2)-a(2)*y(n);
    z(2) = b(3)*x(n)-a(3)*y(n);
end

