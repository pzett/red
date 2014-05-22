function [ decoded ] = demodulate_OFDM(r,FS,S,P,Nc)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
 n_cols = length(r)/(S+P+FS);
    r_matrix = reshape ( r , S+P+FS ,n_cols); % divide signal into colums containing the OFDM symbols
    decoded = [];
    cp1 = zeros(P,n_cols); % variable to save cyclic prefix before
    cp2 = zeros(P,n_cols); % variable to save cyclic prefix after, these might be unused
decoded = [];
    cp1 = zeros(P,n_cols); % variable to save cyclic prefix before
    cp2 = zeros(P,n_cols); % variable to save cyclic prefix after, these might be unused
    %inv_win= gausswin(FS).^(-1);
    inv_win = ones(FS,1);
    for(k=1:n_cols)
        data_with_cp = r_matrix(:,k); % extract columns
        cp1(:,k) = data_with_cp(1:P);
        cp2(:,k) = data_with_cp(end-S-P+1:end-S);
        data = [data_with_cp(P+1:end-S)]; %remove cyclic prefix and suffix
        info = fft(inv_win.*data,FS); %apply FFT
        D = Nc;
        demod = [info(1:D/2); info(FS-((D/2)-1):FS)]; % demodulated symbols
        decoded = [decoded; demod]; % merge into decoded
    end

end