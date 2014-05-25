function [vec_name,vec_size] = bytestobitsnew(str,filename,L)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
length_size = 56;
length_name = 512;

% fid = fopen(str);
% 
% vec3 = fread(fid);
% 
% [M,N] = size(vec3);
% 
% x = dec2bin(vec3,8);
% 
% 
% vec = empty(1,size(x,1)*8);
% for i = 1:size(x,1)
%     vec =[vec x(i,:)];
% end

vec_size_i=L;

aux=dec2bin(vec_size_i);
temp1=[];
for i=1:length(aux)
    temp1=[temp1 str2num(aux(i))];
end

vec_size = [zeros(1,length_size-length(temp1)) temp1 ];

% vec =[];
% for i = 1:size(x,1)
%     for(k=1:8)
%         aux = str2num(x(i,k));
%         vec =[vec aux];
%     end    
% end


% binranges = 0:255;
% bincounts = histc(vec3,binranges);
% stem(binranges,bincounts);
% 
% seq = x;
% [dict,avglen] = huffmandict(binranges,bincounts/length(vec3));
% comp = huffmanenco(vec3,dict); % Encode the data.

% counts = bincounts;
% counts(counts==0)=[];
% 
% code = arithenco(vec3, counts)

vec_name_i=dec2bin(filename,8);

aux2=[];
for i = 1:size(vec_name_i,1)
    aux2 =[aux2 vec_name_i(i,:)];
end

temp2=[];
for i=1:length(aux2)
    temp2=[temp2 str2num(aux2(i))];
end

vec_name=[temp2 zeros(1,8) randint(length_name-length(aux2)-8,1,2)'];

end

