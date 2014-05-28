function [ n_samp,value] = synch2( r,ts )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% find the cross-correlation of the received and the training sequence

x_complex = xcorr(r,ts);%cross-correlate
x = abs(x_complex);  %we want to compare the absolute values for different 
     
%time shifts

size_x=size(x);

[value, offset] = max(x);
%sampling time is given by the positive time shift that maximizes the cross 
%correlation:
n_samp = (offset - (size_x(1)+1)/2);       

end

