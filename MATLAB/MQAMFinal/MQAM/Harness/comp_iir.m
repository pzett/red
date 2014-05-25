function [  ] = comp_iir()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fileID = fopen('rx_b.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
rx_b=zeros(L,1);
for(k=2:L+1)
    rx_b(k-1) = data(k);
end

fileID = fopen('rx_a.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
rx_a=zeros(L,1);
for(k=2:L+1)
    rx_a(k-1) = data(k);
end

rx_a(1:10)'
[rx_aML,b,a ] = peakEQ(rx_b,6.8);
rx_aML(1:10)
b
a
end

