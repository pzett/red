function [ decodedData ] = LDPCdec( rx,coderate )
%LDPCDEC Summary of this function goes here
%   Detailed explanation goes here
size_columns = 64800;
if(mod(length(rx),size_columns) ~= 0 )
   rx = [rx; zeros(size_columns-mod(length(rx),size_columns),1)];
end

rx_matrix = reshape(rx, 64800, length(rx) / 64800);

PM=dvbs2ldpc(coderate, 'indices');
 hDec = comm.LDPCDecoder('ParityCheckMatrix',PM);
 %decoded_bits   = double(step(hDec, demodSignal));
 decodedData = [];
for(k=1:size(rx_matrix,2))
    aux = step(hDec, rx_matrix(:,k));
    decodedData = [decodedData; double(xor(aux,ones(length(aux),1)))];
end

end

