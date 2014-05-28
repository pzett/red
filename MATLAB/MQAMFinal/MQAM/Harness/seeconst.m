system('adb devices')

filename = 'demconst.txt';
copy_file_from_sdcard(filename,'4df789074129bfb5')
close all


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

scatterplot(mconst(1:end-2000)); grid on

% fileID = fopen('rx_signal.txt','r');
% formatSpec = '%f';
% data = fscanf(fileID,formatSpec);
% L=data(1);
% receive=zeros(L,1);
% for(k=2:L+1)
%     receive(k-1) = data(k);
% end
% figure(2)
% pwelch(receive);