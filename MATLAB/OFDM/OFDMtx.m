filename = 'try1.txt';

L_estim = 13;
Q=3;
Nsymb=(Q-1)*L_estim;
a=0.2;
sync_seq_len= 2000;

mu=0.15;
Ns= Nsymb+L_estim;%--> size of the block of symbols transmitted through the ifft\

fmin=0.05;%--> minimum frequency

Nz=ceil(fmin/(1-2*fmin)*(2*Ns+1)); %--> integer number of zeros added 
Np=2*(Ns+Nz)+1 ; % # of pilot tones is L_estim
prefix_length = 35;

%bits = readfile(filename); % Read the text file 

bits=randint(3000,1,2);
data=bits;
M = 4;%2;
d = log2(M); 
bits=reshape(bits,d,length(bits)/d); 
[vec]=grayperm(d);

symb = (bits'*2.^(d-1:-1:0)')'; %--> convert to decimal 
save symb.txt symb -ascii;
symb_g=vec(symb+1); %--> gray mapping 
symb_g=symb_g(:);


val = 1;
if val == 1 % method is 'PSK'
    sig=exp(1i*2*pi/M*symb_g);
elseif val == 2
sig = (dmodce(symb,1,1,'qask')).'; % method = QASK else
    disp('Wrong modulation specified');
end
sig_ifft = make_blocks(sig,Nsymb);

q = floor(Q/2);
[m,n]=size(sig_ifft);
app=[sig_ifft(1:q,:)];

for k=0:L_estim-2
app=[app;ones(1,n);sig_ifft(q+1+k*(Q-1):q+(k+1)*(Q-1),:)];
end

app = [app;ones(1,n);sig_ifft(q+1+(L_estim-1)*(Q-1):end,:)]; 
sig_ifft = app;

% flip zero pad
sig_ifft = [zeros(Nz+1,n); sig_ifft; flipud(conj(sig_ifft));zeros(Nz,n)];
[m,n]=size(sig_ifft);
indx = [fliplr([Nz+2+q-Q:-Q:2]) [Nz+1+2*Ns-q+Q:Q:m]];
sig_ifft(indx)=1;
u=ifft(sig_ifft,Np);
u= Np*real(u); %Energy of 1

u = rescale_data(u,0.99); % Rescale the data to the range -0.5 to 0.5
u = [u((Np-prefix_length+1):Np,:);u]; % add cyclic prefix to each block
u = add_sync_header_seq(u,M,Ns);
fs = 44100;
wavwrite(u(:),fs,'mod_signal.wav');
mod_signal=u;

wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('OFDM.mat','M','prefix_length','L_estim','Q','Ns','fmin','a','mu','sync_seq_len','data');

mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds

fprintf('Modulated signal: %g seconds long \n',mod_signal_length)
