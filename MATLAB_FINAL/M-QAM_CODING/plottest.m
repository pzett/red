clear
close all
load('qamtest01.mat');
figure(1)
semilogy(EbN0,BER2,'r','LineWidth',1.5);

%semilogy(EbN0,BERD(:,end),'r','LineWidth',1.5);
hold on
%M=4.^(1:5);
M=4^4;
BERt=zeros(length(M),length(EbN0));
for(indM=1:length(M))
  BERt(indM,:)=berawgn(EbN0,'qam',M(indM));
end
semilogy(EbN0,BERt(1,:),...
         'LineWidth',1.5);
xlabel('E_b/N_0 [dB]'); ylabel('BER');
title('M-QAM error probability');
%legend('M=4','M=16','M=64','M=256','M=1024');
legend('M=256');

grid on;
axis([0 30 10e-7 1]);
