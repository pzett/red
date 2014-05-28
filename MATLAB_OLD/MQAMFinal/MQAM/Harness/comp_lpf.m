function [ ] = comp_lpf()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
fileID = fopen('Hx.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
Hx=zeros(L,1);
for(k=2:L+1)
    Hx(k-1) = data(k);
end

fileID = fopen('Vx.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
Vx=zeros(L,1);
for(k=2:L+1)
    Vx(k-1) = data(k);
end

Hd=lpf(9,3900);
Hd.numerator
HxML=filter(Hd,Vx);
HxML(20:30)
Hx(20:30)
            

end

