function [vec] = bytestobits(filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(filename);

vec3 = fread(fid);

[M,N] = size(vec3);

x = dec2bin(vec3,8);
vec =[];
for i = 1:size(x,1)
    for(k=1:8)
        aux = str2num(x(i,k));
        vec =[vec aux];
    end    
end
%   s_name='data5kB.txt'; % name of source file

% figure(4)
% binranges = 1:255;
% bincounts = histc(vec3,binranges);
% stem(binranges,bincounts);
end

