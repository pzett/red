function A = num2binmap(Y)
% Usage: A = num2binmap(Y)
% Finds the binary equivalent of a number
% Inputs: Y - numbers
% Output: A- bin data
    X = dec2bin(Y);
    Z = X';
    A = str2num(Z(:))';


end

