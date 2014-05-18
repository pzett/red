function [ encodedData ] = LDPCenc( input_data,coderate )
%LDPCENC Encode with LDPC 
%   code rate Possible values for R are 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6,
%    8/9, and 9/10.

size_columns = coderate * 64800;
PM=dvbs2ldpc(coderate, 'indices');
hEnc = comm.LDPCEncoder('ParityCheckMatrix',PM);

if(mod(length(input_data),size_columns) ~= 0 )
    aux = randint(size_columns-mod(length(input_data),size_columns),1,2);
    input_data = [input_data;aux];
end

input_matrix = reshape(input_data,size_columns,length(input_data)/size_columns);
encodedData = [];
for(k=1:size(input_matrix,2))
    encodedData = [encodedData; double(step(hEnc, input_matrix(:,k)))];
end


%l_data=logical(input_data);
%encodedData    = double(step(hEnc, input_data));
end