

close all

fileID = fopen('tx_signal.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
transm=zeros(L,1);
for(k=2:L+1)
    transm(k-1) = data(k);
end
figure(1)
pwelch(transm);

fileID = fopen('rx_signal.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
receive=zeros(L,1);
for(k=2:L+1)
    receive(k-1) = data(k);
end
figure(2)
pwelch(receive);

fileID = fopen('rx_signal_afterEQ.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
receive=zeros(L,1);
for(k=2:L+1)
    receive(k-1) = data(k);
end
figure(3)
pwelch(receive);

fileID = fopen('Vx.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
receive=zeros(L,1);
for(k=2:L+1)
    receive(k-1) = data(k);
end
figure(4)
pwelch(receive);
fileID = fopen('Vy.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
receive=zeros(L,1);
for(k=2:L+1)
    receive(k-1) = data(k);
end
figure(5)
pwelch(receive);