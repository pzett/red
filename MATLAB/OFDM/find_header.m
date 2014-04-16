function [M,Ns,Nh] = find_header(rx_signal) %rx_signal- column vector

Nh = 2000;
Nc = 20;
T = 10;
t = [0:Nh-1]';
data = [];
% Make a bank of correlators
for j = 1:6 % There are 6 header sequences
s(1:length(t),j) = cos((pi/T)*(Nc+(j+2))*t);
end
% Convolve the rx signal with the corellators
for j = 1:6
c(:,j) = conv(rx_signal(1:Nh+150),flipud(s(:,j)));% I guess 200points of rx_signal is quite high. Can take 150
end
% Find the maximum
[m n] = max(max(c));
[tmp max_val] = max(c(:,n)) % Just for display. Remove later
switch n
case 1
     M = 4;
     Ns = 39;
case 2
M = 4;
    Ns = 100;
case 3
M = 4;
    Ns = 1000;
case 4
M = 16;
Ns = 10; 
case 5
M = 16;
    Ns = 100;
case 6
M = 16;
Ns = 1000;
otherwise
disp('Constellation size and no of symbols per block cound not be found');
end
end

