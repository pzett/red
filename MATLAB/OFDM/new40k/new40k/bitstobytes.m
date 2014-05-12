function [fid] = bitstobytes(vec,filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[M,N] = size(vec);

r=reshape(vec,8,N/8);

rt=r';

x=bin2dec(rt);

fid = fopen(filename,'w+');

fwrite(fid,x);

fclose(fid);

end