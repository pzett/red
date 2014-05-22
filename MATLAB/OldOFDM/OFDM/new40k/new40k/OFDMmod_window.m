function [data_OFDM] = OFDMmod_window(data,L,M)
%This function creates a downsampled OFDM signal. It takes the input as a
%matrix in which the columns have length FS and contain the data to be
%modulated. Each column is read, IFFT is applied and cyclic suffix and
%prefix are inserted. 
%
%
% INPUT: 
% data      data that has to be modulated        
% L         lentgh of the cyclic prefix
% M         length of the suffix


%data1=reshape(data,N,length(data)/N);

N=size(data,1);                         %Number of subcarriers
win = gausswin(N);
data_OFDM=zeros(N+L+M,size(data,2)); % Initialize matrix

    for i=1:size(data,2)
        data_OFDM(end-N+1-M:end-M,i)=win.*ifft(data(:,i)); %apply FFT to data
        data_OFDM(1:L,i)=data_OFDM(end-L+1-M:end-M,i); % apply prefix
        data_OFDM(end-M+1:end,i)=data_OFDM(L+1:L+M,i); % apply suffix
    end
    
data_OFDM=reshape(data_OFDM,size(data_OFDM,2)*(N+L+M),1); % return as a vector.

end
