function [ decoded,pilots  ] = remove_pilots(rx,int,len,ts_length)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Remove pilots to estimate phase and amplitude using the known symbols.
% These estimations are later used in the decoding algorithm.
% The pilots are not very helpful for the case in hand, since the channel
% is time-invariant. Anyways here is the function to estimate the channel
% after int bits have been sent.
rx = reshape(rx,length(rx),1);
decoded_ts = rx(1:ts_length);
rx_data = rx(ts_length+1:end);
if(length(rx_data) < int ) 
    pilots = [];
    decoded = rx;
    return;
end

if(mod(length(rx_data), int+len) ~= 0)
    rx_data = [rx_data; zeros(int+len-mod(length(rx_data),int+len),1)];
end

no_cols = length(rx_data)/(int+len);
rx_data_matrix = reshape(rx_data,int+len,no_cols);
pilots = zeros(len,no_cols);
decoded = [];

for(k=1:no_cols)
    aux=rx_data_matrix(:,k);
    pilots(:,k) = aux(end-len+1:end);
    decoded = [decoded; aux(1:end-len)];
end

decoded = [decoded_ts; decoded];
end

