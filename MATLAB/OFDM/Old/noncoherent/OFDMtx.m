clear all
close all
filename = 'try1.txt';

Ns=40; %--> size of the block of symbols transmitted through the ifft
fmin=0.2;%--> minimum frequency 
Nz=ceil(fmin/(1-2*fmin)*(2*Ns+1)); %--> integer number of zeros added 
Np=2*(Ns+Nz)+1;
prefix_length = 80;
sync_seq_len=2000;
symb = readfile(filename); % Read the text file 
M = 2;
mu=0.15
af=0.2;
d = log2(M);
L_estim=16;
sig_ifft = make_blocks(symb',Ns-2);
[m n] = size(sig_ifft);
sig_ifft = [sig_ifft;zeros(2,n)];
gain= [ones(1,3) ones(1,8)+.1.*[1:8] ones(1,2) ones(1,14)+0.1.*[1:14] ones(1,13)]';
[m,n] = size(sig_ifft);
a = [zeros(11,n); 0.8*zeros(2,n) ;zeros(14,n)+.3; zeros(13,n)+1.5]; 
sig_ifft1= diag(gain)*sig_ifft+a;
sig_ifft = [zeros(Nz+1,n); sig_ifft; flipud(conj(sig_ifft));zeros(Nz,n)];
u=ifft(sig_ifft,Np);
u=Np*real(u); %Energy of 1

u = rescale_data(u,0.99); % Rescale the data to the rance 1
u = [u((Np-prefix_length+1):Np,:);u]; % add cyclic prefix to each block % Add synchronization sequence of size N
u = add_sync_header_seq(u,M,Ns);
u = make_blocks(u,Np+prefix_length);
save -ascii tx_file.txt u; % save the file as ascii characters Fs = global_var(10);

fs = 44100;
wavwrite(u(:),fs,'mod_signal.wav');
mod_signal=u;

wavwrite(mod_signal(:), fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('OFDM.mat','M','prefix_length','L_estim','Ns','fmin','af','mu','sync_seq_len');

mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds

fprintf('Modulated signal: %g seconds long \n',mod_signal_length)
