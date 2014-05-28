function [ data_OFDM ] = modulate_OFDM_asym( mconst,Nc,FS,P,S,high)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

num_cols=length(mconst)/Nc; %divide in columns of the size of virtual carriers
data_matrix = reshape(mconst, Nc, num_cols);
unmod_data=zeros(FS,num_cols); %generate matrix
low = Nc - high;

for (k=1:num_cols)
    info=zeros(FS,1); %generate column to be filled with info
    data=data_matrix(:,k);%read first column
    D=length(data); % D should be Nc
    info(1:high) = [data(1:high).']; %fill first half
    info((FS-low+1):FS) = [data((D-low+1):D).']; % fill second half, zeros in the middle  
    unmod_data(:,k) = info; % fill the column
end

data_OFDM = OFDMmod(unmod_data,P,S); % do the fft and insert cyclic prefix

end