%clear
close all
load('noise.mat');
load('sweep.mat');
%noise
x_no=X;
y_no=r(58636:58636+length(x_no)-1);
%sweep
x_sw=y';
y_sw=rsweep(48086:48086+length(x_sw)-1);
%cleanup
clear X r y rsweep
fs=44100;
N=45;
%% Noise plots
figure;

[RXn,f]=plotspectrum(x_no);
[RYn,f]=plotspectrum(y_no);

maxRXn=max(RXn);
maxRYn=max(RYn);

RXn=RXn-maxRXn;
RYn=RYn-maxRYn;

subplot(1,2,1);
plot(f*fs/1000,RXn,'k','LineStyle','-','LineWidth', 1.5);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
title('PSD of input signal (WGN)');
axis([0 22.1 min(RXn-3) max(RXn+3)]);
grid on;

subplot(1,2,2);
plot(f*fs/1000,RYn,'k','LineStyle','-','LineWidth', 1.5);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
title('PSD of output signal (WGN as input)');
axis([0 22.1 min(RYn-3) max(RYn+3)]);
grid on;

%% Sweep plots
figure;

[RXn,f]=plotspectrum(x_sw);
[RYn,f]=plotspectrum(y_sw);

maxRXn=max(RXn);
maxRYn=max(RYn);

RXn=RXn-maxRXn;
RYn=RYn-maxRYn;

subplot(1,2,1);
plot(f*fs/1000,RXn,'k','LineStyle','-','LineWidth', 1.5);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
title('PSD of input signal (Chirp)');
axis([0 22.1 min(RXn-3) max(RXn+3)]);
grid on;

subplot(1,2,2);
plot(f*fs/1000,RYn,'k','LineStyle','-','LineWidth', 1.5);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
title('PSD of output signal (Chirp as input)');
axis([0 22.1 min(RYn-3) max(RYn+3)]);
grid on;

%% Get TF
load('tf_coeffs.mat');

%ident
% figure;
% b16=p16z16.num;
% a16=p16z16.den;
% freqz(b16,a16)
% figure;
% b8=p8z8.num;
% a8=p8z8.den;
% freqz(b8,a8)
 data=iddata(y_no,x_no,1/fs);
% 
 Hsys=impulseest(data,N);
 h_fir=Hsys.num;
fvtool(h_fir);
%% Cascade
d=fdesign.parameq('F0,BW,BWp,Gref,G0,GBW,Gp',0.2732,0.15,0.03,0,8,3,5);
Hiir=design(d,'cheby1');
H1=Hiir;
H2=dfilt.dffir(h_fir);
 
Hc=cascade(H1,H2);
% figure;
fvtool(H1)
fvtool(Hc)
 


