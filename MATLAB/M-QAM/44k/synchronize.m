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




fprintf(fileID,'%d\n',L);
bit_stream=randint(L,1,2);
for(k=1:L)
    fprintf(fileID,'%d\n',bit_stream(k));
end
fclose(fileID);

end

