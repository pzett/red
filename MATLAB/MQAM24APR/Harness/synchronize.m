function [ n_samp ] =synchronize()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

fileID = fopen('Hx.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
Hx=zeros(L,1);
for(k=2:L+1)
    Hx(k-1) = data(k);
end

fileID = fopen('Hy.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
Hy=zeros(L,1);
for(k=2:L+1)
    Hy(k-1) = data(k);
end

fileID = fopen('ts_real.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
ts_real=zeros(L,1);
for(k=2:L+1)
    ts_real(k-1) = data(k);
end

fileID = fopen('ts_imag.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
ts_imag=zeros(L,1);
for(k=2:L+1)
    ts_imag(k-1) = data(k);
end

b_train_up = [];
ts_const = ts_real+1i*ts_imag;
for n=1:length(ts_const)
    b_train_up = [b_train_up ts_const(n) zeros(1, 29)];
end

% find the cross-correlation of the received and the training sequence
r=Hx+Hy*1i;
x_complex = xcorr(r,b_train_up);%cross-correlate
x = abs(x_complex);  %we want to compare the absolute values for different 
     stem(x)
%time shifts


size_x=size(x)

[value, offset] = max(x);
%sampling time is given by the positive time shift that maximizes the cross 
%correlation:
n_samp = (offset - (size_x(1)+1)/2)




end

