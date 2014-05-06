
load('OFDM.mat');
% rx0 = wavread('mod_signal.wav');
% rx = rx0;
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename); %grab log data
rx=extract_sound_from_log_data(log_data); %extract sound from log data.
plot(rx)
t = [0:sync_seq_len-1]'; 
sync_seq=0.45*sin(2*pi*mu/sync_seq_len*t.^2);
sync_seq_mod = sync_seq.*sin(2*pi*a*t);% Modulated sync seq 
rx_baseband = rx.*sin(2*pi*a*[0:length(rx)-1]');% bring the signal to baseband to do matched filtering 
z=conv(rx_baseband,flipud(sync_seq)); %convolve with only part of the signal to make fast
[tmp start] = max(abs(z))
[M Ns header_len] = find_header(rx(start+L_estim+1:end)); % Calculate the header and get data with header stripped off
go_back = 5;
rx = rx(start-go_back+L_estim+header_len+1:end); % strip off the sync sequence and the header
Nz=ceil(fmin/(1-2*fmin)*(2*Ns+1)); %--> integer number of zeros added 
Np=2*(Ns+Nz)+1 ; % # of pilot tones is L_estim

q = floor(Q/2);

rx = make_blocks(rx,Np+prefix_length);
rx = rx(prefix_length+1:Np+prefix_length,:);%remove_cyclic_prefix 
est_u = fft(rx,Np);
ind_p=[fliplr([Nz+2+q-Q:-Q:2]) [Nz+2+q:Q:Np]];
A = (ind_p(:)*(0:L_estim-1))/Np
Mat = exp(-j*2*pi*A);
cond(Mat)
h_estm=pinv(Mat)*[est_u(ind_p,:)];
H_estim = fft(real(h_estm),Np); % imaginary part due to noise 
[m,n]=size(est_u);
hat_est_u = est_u.*conj(H_estim);
hat_est_u = hat_est_u(Nz+2:Nz+1+Ns,:); % strips zeros and flipped version
app = [hat_est_u(1:q,:)];
for k = 0:L_estim-2
app = [app;hat_est_u(q+2+k*Q:q+(k+1)*Q,:)];
end
app = [app;hat_est_u(q+2+(L_estim-1)*Q:end,:)];


sig_fft = app;
d = log2(M);
[vec]=grayperm(d);


val  = 1;
if val == 1 % method is 'PSK'
        %****** demodulate PSK
dec=exp(-j*2*pi/M*vec).'*sig_fft(:).'; %--> deciding is combined with the gray demapping
        [value,dec]=max(real(dec));
        dec=dec-1;
elseif val == 2
        % put ASK modulation
dec = ddemodce(sig_fft,1,1,'qask',M); % demodulation ASK
else
disp('Wrong modulation specified');
end


filename = 'try1.txt';
bits = data; % Read the text file

d = log2(M);
bits=reshape(bits,d,length(bits)/d); 
[vec]=grayperm(d);
symb= (bits'*2.^(d-1:-1:0)')'; %--> convert to decimal
err = length(find(dec(1:length(symb))~=symb));
ber = err/length(symb)
% writefile(dec);
% fd = fopen('try1.txt');
% in = fread(fd);
% fd2 = fopen('write.txt');
% out = fread(fd2);
% err1 = length(find(out(1:length(in))~=in)) 
% cer = err1/length(in)