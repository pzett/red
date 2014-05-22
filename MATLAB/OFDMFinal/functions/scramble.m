function [data_scrambled] = scramble( data )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

H = commsrc.pn('GenPoly',       [20 17 0], ...
              'InitialStates', [zeros(1,19) 1],   ...
              'CurrentStates', [zeros(1,19) 1],   ...
              'Mask',          [zeros(1,19) 1] );
              


set(H, 'NumBitsOut', length(data));
PN = generate(H);
data = reshape(data,length(data),1);
data_scrambled = xor(data,PN);
end

