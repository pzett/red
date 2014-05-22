function [ par ] = compute_par( data )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

par = max(abs(data)) / ((data'*data)/length(data));

end

