function [ ro ] = load_data_from_file( filename,levels)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

fileID = fopen(filename,'r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);

ro=zeros(L,1);

for(k=2:length(ro)+1)
    ro(k-1)=data(k);
end

end

