function [ mconst_outML ] = comp()
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
fileID = fopen('decision.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
decision=zeros(L,1);
for(k=2:L+1)
    decision(k-1) = data(k);
end

fileID = fopen('bits.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
bits=zeros(L,1);
for(k=2:L+1)
    bits(k-1) = data(k);
end

stem(bits~=decision(1:length(bits)))