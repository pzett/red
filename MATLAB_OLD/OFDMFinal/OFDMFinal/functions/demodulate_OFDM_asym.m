function [ decoded ] = demodulate_OFDM_asym(r,FS,S,P,Nc,high,window)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Demodulate OFDM symbols by first removing prefixes and then applying FFT
n_cols = length(r)/(S+P+FS);
r_matrix = reshape ( r , S+P+FS ,n_cols); % divide signal into colums containing the OFDM symbols
decoded = [];
cp1 = zeros(P,n_cols); % variable to save cyclic prefix before
cp2 = zeros(P,n_cols); % variable to save cyclic prefix after, these might be unused

low = Nc - high; % number of subcarriers below carrier frequency

if(window)
inv_win = 1./gausswin(FS+S+P,1);
inv_win = inv_win(P+1:end-S);
else
inv_win = ones(FS,1); % if you apply window, put yours here ;)
end

for(k=1:n_cols)
    data_with_cp = r_matrix(:,k); % extract columns
    cp1(:,k) = data_with_cp(1:P);
    cp2(:,k) = data_with_cp(end-S-P+1:end-S);
    data = [data_with_cp(P+1:end-S)]; %remove cyclic prefix and suffix
    info = fft(inv_win.*data,FS); %apply FFT
    demod = [info(1:high); info(FS-low+1:FS)]; % demodulated symbols
    decoded = [decoded; demod]; % merge into decoded
end


end

  