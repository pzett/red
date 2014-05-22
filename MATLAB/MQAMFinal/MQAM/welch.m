


fileID = fopen('tx_signal.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
transm=zeros(L,1);
for(k=2:L+1)
    transm(k-1) = data(k);
end

pwelch(transm);

fileID = fopen('rx_signal.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
receive=zeros(L,1);
for(k=2:L+1)
    receive(k-1) = data(k);
end

pwelch(receive);