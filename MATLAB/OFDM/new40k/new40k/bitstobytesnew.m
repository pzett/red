function [fid] = bitstobytesnew(vec)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
length_size = 128;
length_name = 512;

[M,N] = size(vec);

r=reshape(vec,8,N/8);

rt=r';
rt2=num2str(rt);
x=bin2dec(rt2);

% First 128 bits is size of file
temp1=[];
i=1;
size_bits = zeros(length_size,1);

while x(i)~=0
   temp1=[temp1 x(i)];
   i=i+1;
end

str = native2unicode(temp1,'UTF-8');
sizeoffile=bin2dec()
% Then name of file
temp2=[];
j=length_size;
while x(j+1)~=0
   temp2=[temp2 x(j)];
   j=j+1;
end

str2 = native2unicode(temp2,'UTF-8');

% Turn size of file to num
sizeoffile = str2num(str);

fid = fopen(str2,'w+');

fwrite(fid,x(length_size+length_name:sizeoffile/8));

fclose(fid);

end