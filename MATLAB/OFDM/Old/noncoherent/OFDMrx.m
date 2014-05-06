
load('OFDM.mat');
rx0 = wavread('mod_signal.wav');

rx=rx0;
save rx.txt rx -ascii;
plot(rx);
%---> matched filter

t = [0:sync_seq_len-1]'; 
sync_seq=0.45*sin(2*pi*mu/sync_seq_len*t.^2);
sync_seq_mod = sync_seq.*sin(2*pi*af*t);% Modulated sync seq 
rx_baseband = rx.*sin(2*pi*af*[0:length(rx)-1]');% bring the signal to baseband to do matched filtering 
z=conv(rx_baseband,flipud(sync_seq)); %convolve with only part of the signal to make fast
[tmp start] = max(abs(z))
plot(z);

%--->Calculating the header
[M Ns header_len] = find_header(rx(start+L_estim+1:end)); % Calculate the header and get data with header stripped off 
Nz=ceil(fmin/(1-2*fmin)*(2*Ns+1));
Np=2*(Ns+Nz)+1;
d = log2(M);

go_back = 65;
rx = rx(start-go_back+L_estim+header_len+1:end); % strip off the sync sequence and the header
rx = make_blocks(rx,Np+prefix_length);
rx = rx(prefix_length+1:Np+prefix_length,:);%remove_cyclic_prefix
est_u = fft(rx,Np);
[l k] = size(est_u);
est_u = est_u(Nz+2:(Ns+Nz+1),:); % remove the zeros and flipped stuff 
hat_est_u = abs(est_u);
No = 0.01;
[m,n] = size(hat_est_u);
T = sqrt(2)*abs(Hmmse)/2; % threshold vector
mtx_T = diag(T)*ones(m,n);
a = find(hat_est_u<=mtx_T);
hat_symb = ones(m,n);
hat_symb(a) = 0;
hat_symb = hat_symb(1:Ns-2,:);
dec = hat_symb(:);
writefile(dec);