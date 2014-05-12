function [vec] = bytestobits(filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
fid = fopen(filename);

vec3 = fread(fid);

[M,N] = size(vec3);

x = dec2bin(vec3);
vec =[];
for i = 1:size(x,1)
    vec =[vec x(i,:)];
end

end

