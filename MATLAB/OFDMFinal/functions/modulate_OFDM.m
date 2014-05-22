function [ data_OFDM ] = modulate_OFDM( mconst,Nc,FS,P,S,window)
%Author : Red Group - Francisco Rosario (frosario@kth.se)

num_cols=length(mconst)/Nc; %divide in columns of the size of virtual carriers
data_matrix = reshape(mconst, Nc, num_cols);
unmod_data=zeros(FS,num_cols); %generate matrix
for (k=1:num_cols)
    info=zeros(FS,1); %generate column to be filled with info
    data=data_matrix(:,k);%read first column
    D=length(data); % D should be Nc
    info(1:(D/2)) = [data(1:(D/2)).']; %fill first half
    info((FS-((D/2)-1)):FS) = [data(((D/2)+1):D).']; % fill second half, zeros in the middle
    unmod_data(:,k) = info; % fill the column
end

data_OFDM = OFDMmod_window(unmod_data,P,S,window); % do the fft and insert cyclic prefix

end