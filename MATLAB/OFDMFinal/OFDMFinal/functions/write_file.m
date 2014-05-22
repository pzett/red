function [ output_args ] = write_file( vec )
%UNTITLED3 Summary of this function goes here
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


bin_fid2=fopen('decoded.bin','w'); %create binary file
fprintf(bin_fid2,'%1d',vec(length_size+length_name+1:length_size+length_name+sizeoffile)); %stores decoded data in file
fclose(bin_fid2);
decodeASCII('decoded.bin',str); %converts binary string to text

end

