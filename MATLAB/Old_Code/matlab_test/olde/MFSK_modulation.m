function [ MFSK_signal ] = MFSK_modulation( data )
%MFSK_MODULATION Summary of this function goes here
%   Detailed explanation goes here

tsequence =[ 0 0 0 1 0 0 0 1 1 1 1 1 0 0 1 0 1 1 0 1]; %length 20
save('tsequence.mat','tsequence');

%Initialize variables

fs=44100; %Sampling frequency

Tb=50/fs; %Bit period

Nb=1000; %Number of bits to transmit

fc=3000; %central frequency

M=4;

deltafc=1/Tb;
f=zeros(1,M);
alfa=zeros(1,M); %variable to construct the working frequencies
for(m=1:M)
    alfa(m)=2*m-1-M;
    f(m)=fc+alfa(m)*deltafc;
end

gb_length=10; %length of guard band
guard=round(rand(1,gb_length)); %generate guard band
bit_stream = [guard tsequence data]; %merge the bits together

% Time for one bit
t = 0 : 1/fs : Tb-1/fs;

time = []; % complete time
MFSK_signal = []; %Signal to transmit
 
t_tot=t; %auxiliary variable

%Generate FSK_signal
for ii = 1:log2(M):length(bit_stream)
    MFSK_signal = [MFSK_signal (bit_stream(ii)==0 && bit_stream(ii+1)==0)*cos(2*pi*f(1)*t)+...
                        (bit_stream(ii)==1 && bit_stream(ii+1)==0)*cos(2*pi*f(2)*t)+...
                        (bit_stream(ii)==1 && bit_stream(ii+1)==1)*cos(2*pi*f(3)*t)+...
                        (bit_stream(ii)==0 && bit_stream(ii+1)==1)*cos(2*pi*f(4)*t)];
    time=[time t_tot];
    t_tot=t_tot+Tb;
         
end




end

