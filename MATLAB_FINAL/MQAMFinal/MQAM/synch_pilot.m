function [ ] = synch_pilot(r,pil_const,pilot_int, Q ,pil_len,ts_len)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

b_train_up = [];
for n=1:length(pil_const)
    b_train_up = [b_train_up pil_const(n) zeros(1, Q-1)];
end

r = r(ts_len*Q+1:end)
no_pilots = floor(length(r)/(Q*(pilot_int+pil_len)));
margin = 100;
figure
for(k=1:no_pilots)
aux = r((Q*k*pilot_int-margin)+(k-1)*Q*pil_len:(k*(Q*pilot_int+Q*pil_len)+margin));
x = abs(xcorr(aux,b_train_up));
[value, offset] = max(x);

end
% find the cross-correlation of the received and the training sequence

%x_complex = xcorr(r,b_train_up);%cross-correlate
  %we want to compare the absolute values for different 
     
%time shifts


size_x=size(x);


%sampling time is given by the positive time shift that maximizes the cross 
%correlation:
n_samp = (offset - (size_x(2)+1)/2);       

end

