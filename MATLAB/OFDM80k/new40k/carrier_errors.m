function [ output_args ] = carrier_errors( tx,rx,Nc )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
tx = reshape(tx,1,length(tx));
rx = reshape(rx,1,length(rx));
if(mod(length(tx),Nc) ~= 0)
tx= [tx zeros(1,Nc-mod(length(tx),Nc))];
rx= [rx zeros(1,Nc-mod(length(rx),Nc))];
end

tx = reshape(tx,Nc,length(tx)/Nc);
rx = reshape(rx,Nc,length(rx) / Nc);
errors = zeros(1,Nc);
for(k=1:Nc)
    errors(k) = sum(tx(k,:) ~= rx(k,:));
end
stem(errors); xlabel('Carrier number');
             ylabel('Number of errors');  
             title('Errors in different carriers');

end

