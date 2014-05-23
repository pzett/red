function [ gama ] = skew_estimation( r, b_train_qam)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
gama=0;
size_b=size(b_train_qam);
%estimate the phase shift based on known train sequence
total = 0;
for k=1:size_b(2)
    if imag(r(k))/imag(b_train_qam(k)) < 1 && imag(b_train_qam(k))>6 && imag(b_train_qam(k))>6
    aux = acos(imag(r(k))/imag(b_train_qam(k)));
    gama = gama + aux;
    total =total +1;
    end

end

gama = gama / total ;
