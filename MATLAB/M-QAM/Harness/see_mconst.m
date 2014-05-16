function [  ] = see_const()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
close all
fileID = fopen('tx_const.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
mconst=zeros(L,1);
for(k=2:L+1)
    mconst(k-1) = data(k);
end
mreal=mconst(1:2:end-1)
mimag=mconst(2:2:end)

mconst=mreal+1i*mimag;

scatterplot(mconst); grid on


fileID = fopen('mconst_before.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
mconst=zeros(L,1);
for(k=2:L+1)
    mconst(k-1) = data(k);
end
mreal=mconst(1:2:end-1)
mimag=mconst(2:2:end)
mconst=mreal+1i*mimag;
scatterplot(mconst); grid on



fileID = fopen('mconst.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
mconst=zeros(L,1);
for(k=2:L+1)
    mconst(k-1) = data(k);
end
mreal=mconst(1:2:end-1)
mimag=mconst(2:2:end)
mconst=mreal+1i*mimag;
scatterplot(mconst); grid on



fileID = fopen('demconst.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
mconst=zeros(L,1);
for(k=2:L+1)
    mconst(k-1) = data(k);
end
mreal=mconst(1:2:end-1);
mimag=mconst(2:2:end);
mconst=mreal+1i*mimag;
scatterplot(mconst); grid on



fileID = fopen('mconstdemMLx.txt','r');
formatSpec = '%f';
datax = fscanf(fileID,formatSpec);
L=datax(1);
mconst=zeros(L,1);
fileID = fopen('mconstdemMLy.txt','r');
formatSpec = '%f';
datay = fscanf(fileID,formatSpec);
L=datay(1);
mconst=zeros(L,1);
for(k=2:L+1)
    mconst(k-1) = datax(k)+1i*datay(k);
end
scatterplot(mconst); grid on

end