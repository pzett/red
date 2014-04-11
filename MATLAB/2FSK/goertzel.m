function [ decision ] = goertzel( w1,w2,Fs,n,r)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% K computation
k1 = 0.5 + n*w1/Fs; %bit 1
k2 = 0.5 + n*w2/Fs; %bit 2
% Algorithm constants computation
coeff1 = 2*cos((2*pi/n)*k1);
coeff2 = 2*cos((2*pi/n)*k2);

% Initialize buffer values
P2=0; P1=0; P0=0;
Q2=0; Q1=0; Q0=0;
mag1=[];
mag2=[];

for l = 1:length(r)
% For each sample, do the following: 
% 1) Compute Q0 using current sample
P0 = coeff1*P1 - P2 + r(l); % Goertzel 1
Q0 = coeff2*Q1 - Q2 + r(l); % Goertzel 2
% 2) Rotate buffer values and decrement
Q2=Q1; % Goertzel 1
Q1=Q0;
P2=P1; % Goertzel 2
P1=P0;

%3) If n samples taken, compute magnitude and reset buffers
if(mod(l, n) == 0) 
mag1= [mag1 (P1*P1 + P2*P2 - P1*P2*coeff1)];
mag2= [mag2 (Q1*Q1 + Q2*Q2 - Q1*Q2*coeff2)];

Q2=0;Q1=0;Q0=0;
P2=0;P1=0;P0=0;
end
end

for(k=1:length(mag1))
    if(mag1(k)>mag2(k))
        decision(k)=1;
    else
        decision(k)=0;
        
    end
end




end

