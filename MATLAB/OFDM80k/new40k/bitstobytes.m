function [fid] = bitstobytes(vec,filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

str=[];
for i = 1:length(vec)
    
        aux = num2str(vec(i));
        str =[str aux];
        
end

[M,N] = size(str);

r=reshape(str,8,N/8);

rt=r';

x=bin2dec(rt);

fid = fopen(filename,'w+');

fwrite(fid,x);

fclose(fid);

end