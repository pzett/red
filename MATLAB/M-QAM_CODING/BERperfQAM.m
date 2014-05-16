EbN0=0:30;
%M=4.^(1:5);
M=4^4;
BER=zeros(length(M),length(EbN0));
for(indM=1:length(M))
  BER(indM,:)=berawgn(EbN0,'qam',M(indM));
end
semilogy(EbN0,BER(1,:),...
         'LineWidth',1.5);
% semilogy(EbN0,BER(1,:),...
%          EbN0,BER(2,:),...
%          EbN0,BER(3,:),...
%          EbN0,BER(4,:),...
%          EbN0,BER(5,:),...
%          'LineWidth',1.5);
xlabel('E_b/N_0 [dB]'); ylabel('BER');
title('M-QAM error probability');
%legend('M=4','M=16','M=64','M=256','M=1024');
legend('M=256');

grid on;
axis([0 30 10e-7 1]);


