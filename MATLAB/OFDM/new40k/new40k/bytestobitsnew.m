function [vec_name,vec_size] = bytestobitsnew(str,filename)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
length_size = 128;
length_name = 512;

fid = fopen(str);

vec3 = fread(fid);

[M,N] = size(vec3);

x = dec2bin(vec3,8);
vec =[];
for i = 1:size(x,1)
    vec =[vec x(i,:)];
end

vec_size_i=size(vec,2);

aux=dec2bin(vec_size_i,8);
temp1=[];
for i=1:length(aux)
    temp1=[temp1 str2num(aux(i))];
end

vec_size=[zeros(1,length_size-length(temp1)) temp1 ];

vec_name_i=dec2bin(filename,8);

aux2=[];
for i = 1:size(vec_name_i,1)
    aux2 =[aux2 vec_name_i(i,:)];
end

temp2=[];
for i=1:length(aux2)
    temp2=[temp2 str2num(aux2(i))];
end

vec_name=[temp2 zeros(1,length_name-length(aux2))];

end

