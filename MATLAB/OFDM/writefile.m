function writefile(array)
% This function converts the given array of symbols to its ascii number % and writes it into a file
%Usage- writefile(array_of_bits)
%Inputs-
% array- array of symbols
%Outputs- None
% Global Parameters-
% train_seq= training sequence which should be known by the transmitter and the receiver
array_of_bits = num2binmap(array); %COnver the symbols to binary digits
x = num2str(array_of_bits(:)).'; % Done for proper arrangement 
len = length(x) - mod(length(x),7);
x = x(:,1:len); % Truncate to the nearest integer divisible by 7
rows = ceil(length(x)/7); % find the number of rows required
array = reshape(x,7,rows); % arrange into columns of 7 to be converted to ascii
num = bin2dec(array.'); % COnver into decimal
fdw = fopen('write.txt','w'); % Open file to write
count = fwrite(fdw,num);
fclose(fdw);

end

