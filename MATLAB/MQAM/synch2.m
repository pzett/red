function [ n_samp ] = synch2(r,ts_const, Q )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

b_train_up = [];
for n=1:length(ts_const)
    b_train_up = [b_train_up ts_const(n) zeros(1, Q-1)];
end

% find the cross-correlation of the received and the training sequence

x_complex = xcorr(r,b_train_up);%cross-correlate
x = abs(x_complex);  %we want to compare the absolute values for different 
     
%time shifts
figure(6)   
stem(x)

size_x=size(x)

[value, offset] = max(x);
%sampling time is given by the positive time shift that maximizes the cross 
%correlation:
n_samp = (offset - (size_x(2)+1)/2);       

end

