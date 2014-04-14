function [ block] = add_sync_header_seq(data,const_size,pkt_size)


sync_seq_len= 2000;
a =0.2;
mu =0.15;
t = [0:sync_seq_len-1]';
sync_seq=0.45*sin(2*pi*mu/sync_seq_len*t.^2);
L_estim = 16;
sync_seq_mod = [sync_seq.*sin(2*pi*a*t); zeros(L_estim,1)];% Modulated sync seq

% Make header of size Nh
Nh = 2000;
Nc = 20;
T = 10;
time = [0:Nh-1]';

if ((const_size == 4) & (pkt_size == 39)) %-- >modifying pkt_size is Ns
header = 0.45*cos((pi/T)*(Nc+3)*time);% 3 since the frequency should be > 0.1
elseif ((const_size == 4) & (pkt_size == 100)) header = 0.45*cos((pi/T)*(Nc+4)*time);
elseif ((const_size == 4) & (pkt_size == 1000)) header = 0.45*cos((pi/T)*(Nc+5)*time);
elseif ((const_size == 16) & (pkt_size == 10)) header = 0.45*cos((pi/T)*(Nc+6)*time);
elseif ((const_size == 16) & (pkt_size == 100)) header = 0.45*cos((pi/T)*(Nc+7)*time);
elseif ((const_size == 16) & (pkt_size == 1000)) header = 0.45*cos((pi/T)*(Nc+8)*time);
else
disp('There is some error in the values of const_size and pkt_size');
end
%Add the sync and header to the data
block = [sync_seq_mod;header;data(:)];


end

