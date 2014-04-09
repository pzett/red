function [ FSK_signal ] = FSK_modulation( data, fs )
%FSK_MODULATION Summary of this function goes here
%   Detailed explanation goes here


% Define the two frequencies 
% Frequency component for bit 1
f1 = 2500+4*fs/200; 
% Frequency component for bit 0 
f2 = 2500;

Tb=200/fs; %Bit period

gb_length=10; %length of guard band
ts_length=20; %length of training sequence

guard=round(rand(1,gb_length)); %generate guard band
%tsequence=round(rand(1,ts_length)); %generate random tsequence

%% Good correlation Training sequences
% tsequence =[0 0 0 0 1 1 0 1]; %length 8
% tsequence =[0 0 1 1 0 0 0 0 0 1 0 1]; %length 12
% tsequence =[0 0 0 0 0 1 1 0 0 1 1 0 1 0 1 1]; %length 16
 tsequence =[ 0 0 0 1 0 0 0 1 1 1 1 1 0 0 1 0 1 1 0 1]; %length 20
% tsequence =[0 0 0 1 1 1 1 1 1 0 0 1 0 0 0 0 1 1 0 0 1 0 1 0]; %length 24 





save('tsequence.mat','tsequence');
bit_stream = [guard tsequence data]; %merge the bits together


t = 0 : 1/fs : Tb-1/fs;%time for one bit
FSK_signal = []; %Signal to transmit

for ii = 1:length(bit_stream)
    
    FSK_signal = [FSK_signal (bit_stream(ii)==1)*cos(2*pi*f1*t)+...
                             (bit_stream(ii)==0)*cos(2*pi*f2*t)    ];
                         
end





end

