function [ pilots decoded  ] = remove_pilots(rx,int,p_length,ts_length)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Remove pilots to estimate phase and amplitude using the known symbols.
% These estimations are later used in the decoding algorithm.
% The pilots are not very helpful for the case in hand, since the channel
% is time-invariant. Anyways here is the function to estimate the channel
% after int bits have been sent.

decoded_ts = rx(1:ts_length);
rx_data = rx(ts_length+1:end);
if(length(rx_data) < int ) 
    pilots = [];
    decoded = rx;
    return;
end

if(mod(length(rx_data), int+p_length) ~= 0)
    rx_data = [rx_data; zeros(int+p_length-mod(length(rx_data),int+p_length),1)];
end

no_cols = length(rx_data)/(int+p_length);
rx_data_matrix = reshape(rx_data,int+p_length,no_cols);
pilots = zeros(p_length,no_cols);
decoded = [];

for(k=1:no_cols)
    aux=rx_data_matrix(:,k);
    pilots(:,k) = aux(end-p_length+1:end);
    decoded = [decoded; aux(1:end-p_length)];
end

decoded = [decoded_ts; decoded];
end

