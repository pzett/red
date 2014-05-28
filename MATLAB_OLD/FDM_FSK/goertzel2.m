function [ decision ] = goertzel2( w1,w2,w3,w4,Fs,n,r)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% K computation
k1 = 0.5 + n*w1/Fs; %bit 00
k2 = 0.5 + n*w2/Fs; %bit 10
k3 = 0.5 + n*w3/Fs; %bit 11
k4 = 0.5 + n*w4/Fs; %bit 01
% Algorithm constants computation

coeff1 = 2*cos((2*pi/n)*k1);
coeff2 = 2*cos((2*pi/n)*k2);
coeff3 = 2*cos((2*pi/n)*k3);
coeff4 = 2*cos((2*pi/n)*k4);

% Initialize buffer values
P2=0; P1=0; P0=0;
Q2=0; Q1=0; Q0=0;
R2=0; R1=0; R0=0;
S2=0; S1=0; S0=0;
mag1=[];
mag2=[];
mag3=[];
mag4=[];

for l = 1:length(r)
% For each sample, do the following: 
% 1) Compute Q0 using current sample
P0 = coeff1*P1 - P2 + r(l); % Goertzel 1
Q0 = coeff2*Q1 - Q2 + r(l); % Goertzel 2
R0 = coeff3*R1 - R2 + r(l); % Goertzel 3
S0 = coeff4*S1 - S2 + r(l); % Goertzel 4
% 2) Rotate buffer values and decrement
Q2=Q1; % Goertzel 1
Q1=Q0;
P2=P1; % Goertzel 2
P1=P0;
R2=R1; % Goertzel 3
R1=R0;
S2=S1; % Goertzel 4
S1=S0;


%3) If n samples taken, compute magnitude and reset buffers
if(mod(l, n) == 0) 
mag1= [mag1 (P1*P1 + P2*P2 - P1*P2*coeff1)];
mag2= [mag2 (Q1*Q1 + Q2*Q2 - Q1*Q2*coeff2)];
mag3= [mag3 (R1*R1 + R2*R2 - R1*R2*coeff3)];
mag4= [mag4 (S1*S1 + S2*S2 - S1*S2*coeff4)];
Q2=0;Q1=0;Q0=0;
P2=0;P1=0;P0=0;
R2=0;R1=0;R0=0;
S2=0;S1=0;S0=0;
end
end
decision=zeros(1,2*length(mag1));

for(k=1:length(mag1))
    [value,l]=max([mag1(k) mag2(k) mag3(k) mag4(k)]);
    
switch l
    case 1
       decision(2*k-1)=0;
       decision(2*k)=0;
       
    case 2
       decision(2*k-1)=1;
       decision(2*k)=0;
       
    case 3
        decision(2*k-1)=1;
        decision(2*k)=1;
    case 4
        decision(2*k-1)=0;
        decision(2*k)=1;
end

end
% for(k=1:length(mag1))
%     if(mag1(k)>mag2(k))
%         decision(k)=1;
%     else
%         decision(k)=0;
%         
%     end
% end
end

