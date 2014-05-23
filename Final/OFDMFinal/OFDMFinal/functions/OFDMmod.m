function [data_OFDM] = OFDMmod(data,L,M,window)
%Authors : Red/Green Groups - Francisco Rosario/Frederic de Poret 
%This function creates a downsampled OFDM signal. It takes the input as a
%matrix in which the columns have length FS and contain the data to be
%modulated. Each column is read, IFFT is applied and cyclic suffix and
%prefix are inserted. PAPR for each OFDM symbol is also computed and plotted. 
%
% INPUT:
% data      data that has to be modulated
% L         lentgh of the cyclic prefix
% M         length of the suffix
% OUTPUT:
% data_OFDM : samples of the OFDM signal ready to be upconverted.



N=size(data,1);                         %Number of subcarriers
data_OFDM=zeros(N+L+M,size(data,2)); % Initialize matrix
papr = zeros(1,size(data,2));
if(window)
    win = gausswin(N+L+M);
else
    win = ones(N+L+M,1);
end

for i=1:size(data,2)
    data_OFDM(end-N+1-M:end-M,i)=ifft(data(:,i)); %apply FFT to data
    data_OFDM(1:L,i)=data_OFDM(end-L+1-M:end-M,i); % apply prefix
    data_OFDM(end-M+1:end,i)=data_OFDM(L+1:L+M,i); % apply suffix
    data_OFDM(:,i)=win.*data_OFDM(:,i);
    papr(i) = compute_par(data_OFDM(:,i));
end

data_OFDM=reshape(data_OFDM,size(data_OFDM,2)*(N+L+M),1); % return as a vector.

figure(2)
stem(papr); title('PAPR amplitude for each OFDM symbol'); xlabel('Symbol'); ylabel('Amplitude');
end
