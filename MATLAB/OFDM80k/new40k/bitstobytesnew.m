function [fid] = bitstobytesnew(vec)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
length_size = 56;
length_name = 512;
r_size = vec(length_name+1:length_name+length_size)';
str_size=num2str(r_size(end-51:end));
sizeoffile = bin2dec(str_size');

[M,N] = size(vec);

r=reshape(vec,8,N/8);
rt=r';
rt2=num2str(rt);
x=bin2dec(rt2);


name = [];
for(k=1:length_name/8)
    aux = x(k);
    if(aux == 0); break;  end;
    name =[name; aux];
    
end


str = native2unicode(name,'US-ASCII');

%str=['/output/',str'];
fid = fopen(str,'w+');

fwrite(fid,x((length_size+length_name)/8+1:(length_size+length_name)/8+sizeoffile/8));

fclose(fid);

end