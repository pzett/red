%OFDM

%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');
%Initialize variables


fs=44100; %Sampling frequency

levels = 1;

% block_size = 64;  %   size of each ofdm block
% cp_len = ceil(0.1*block_size);  %   length of cyclic prefix


FS = 1024; %IFFT/FFT length
q=5; %carrier period to elementary period ratio
Tu = 2*q*FS/fs
% delta_f = fs/1000; % sub-carrier spacing
% Tu = 1 / delta_f; % symbol period
T = 2 * Tu / FS %T/2 is the sub carriers period
delta_f = 1 / Tu

fc=q*1/T %carrier frequency
Nc =256; % Number of active sub-carriers
G = 0;
delta=G*Tu; %guard band duration
Ts=delta+Tu; %total OFDM symbol period

A = 1;

ts_length=3*FS; 
gb_length=3*FS; 
Nb=3*FS;%Number of bits to transmit
ts = randint(ts_length*2*levels,1,2);
gb = randint(gb_length*2*levels,1,2);%zeros(gb_length*2*levels,1);
data = randint(Nb,1,2);
left = rem(Nb+(ts_length+gb_length)*2*levels,2*levels)
bit_stream = [gb' ts' data'  gb'];
L=length(bit_stream);


%Generate auxiliar variables to compute tx_signal with window and RRC

symbol2=ones(1,1);

mx2=[]; my2=[];

x2=0;
y2=0;
for n=0:2*levels:L-2*levels
    bit=[];
    xi=0;
    yi=0;
    
    for m= 1:2:2*levels
        if bit_stream(n+m)==0
            xi=xi+A*(2^((m-1)/2));
            
        else
            xi=xi-A*(2^((m-1)/2));
            
        end
        if bit_stream(n+m+1)==0
            yi=yi+A*(2^((m-1)/2));
            
        else
            yi=yi-A*(2^((m-1)/2));
            
        end
    end
    
    x2=xi*symbol2;
    y2=yi*symbol2;
    
    
    mx2=[mx2 x2];
    my2=[my2 y2];
end

mconst = mx2 + 1i*my2;
if(mod(length(mconst),Nc) ~= 0)
    mconst = [mconst (1+1i)*ones(Nc-mod(length(mconst),Nc),1)'];
end
length(mconst)
num_cols=length(mconst)/Nc;
data_matrix = reshape(mconst, Nc, num_cols);

t=0:1/fs:Tu-1/fs;
up_signal =[];
carriers = [];
Hd=lpf(20,1/T);
[b,a] = butter(13,1/(T*fs)); %reconstruction filter
[H,F] = freqz(b,a,FS,fs);
delay =64;
for (k=1:num_cols)
    info=zeros(FS,1);
    data=data_matrix(:,k);
    D=length(data);
    info(1:(D/2)) = [ data(1:(D/2)).']; %Zero padding
    info((FS-((D/2)-1)):FS) = [ data(((D/2)+1):D).'];
    carriers =  FS.*ifft(info,FS);
    p=1/fs:1/fs:T/2;
    g=ones(length(p),1); %pulse shape
    L=length(carriers);
    chips = [ carriers.'; zeros(2*q-1,L)];
    dummy=conv(g,chips(:));
    u = [dummy; zeros(120,1) ];
    uoft = filter(b,a,u); %baseband signal (D)
    %uoft = filter ( Hd,u);
    s_tilde=(uoft(delay+(1:length(t))).').*exp(1i*2*pi*fc*t);
    up_signal =[up_signal real(s_tilde)]; %passband signal (E) 
end



mod_signal=up_signal/(max(abs(up_signal)+0.001));
ts_mod = up_signal(gb_length/FS*FS/Nc*length(t)+1:gb_length/FS*FS/Nc*length(t)+ts_length/FS*FS/Nc*length(t));
ts_mod=ts_mod/(max(abs(ts_mod)+0.001));

mod_signal = up_signal;
ts_mod = up_signal(gb_length/FS*FS/Nc*length(t)+1:gb_length/FS*FS/Nc*length(t)+ts_length/FS*FS/Nc*length(t));


% wavwrite(mod_signal, fs, 'mod_signal.wav');
% create_file_of_shorts('test_signal.dat',mod_signal*2^14);
% copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );


tt=0:T/2:Tu;
figure(1);
subplot(211);
stem(tt(1:20),real(carriers(1:20)));

subplot(212);
stem(tt(1:20),imag(carriers(1:20)));

figure(2);
f=(2/T)*(1:(FS))/(FS);
subplot(211);
plot(f,abs(fft(carriers,FS))/FS);
subplot(212);
pwelch(carriers,[],[],[],2/T); title('Spectral density of carriers')



figure(3);
stem(p,g); title('Pulse Shape')

figure(4);
subplot(211);
plot(t(1:400),real(u(1:400))); title('After upsampling in time')
subplot(212);
plot(t(1:400),imag(u(1:400)));

figure(5);
ff=(fs)*(1:(q*FS))/(q*FS); 
subplot(211);
plot(ff,abs(fft(u,q*FS))/FS);title('PSD after upsampling')
subplot(212);
pwelch(u,[],[],[],fs);



figure(6);
plot(F,20*log10(abs(H))); title('Frequency response of reconstruction filter')

figure(7);
subplot(211);
plot(t(80:480),real(uoft(80:480)));  title('Baseband Signal after reconstruction')
subplot(212);
plot(t(80:480),imag(uoft(80:480)));
figure(8);
subplot(211);
plot(ff,abs(fft(uoft,q*FS))/FS);
subplot(212);
pwelch(uoft,[],[],[],fs);  title('PSD of Baseband Signal')


figure(9);
plot(t(80:480),up_signal(80:480)); title('Passband Signal in Time')

figure(10);
pwelch(up_signal,[],[],[],fs);


mod_signal = [mod_signal zeros(1,500)];


%OFDM RECEPTION

ro = mod_signal;
t_samp = synch(ro,ts_mod);
r = ro(t_samp:end);

t = 0 : 1/fs : (length(r)-1)/fs
r=exp(-1i*2*pi*fc*t).*r;
figure(11)
pwelch(r,[],[],[],fs);
%Carrier suppression
[B,AA] = butter(13,1/2);
r = 2*filter(B,AA, r);

%r = 2*filter(Hd,r);
figure(12)
pwelch(r,[],[],[],fs);

data = real(r(1:2*q:length(r)))+1i*imag(r(1:2*q:length(r)));
figure(13)
pwelch(data,[],[],[],2/T);


if( mod(length(data),FS) ~= 0 )
    data = [data zeros(1,FS-mod(length(data),FS))];
end

data_matrix = reshape(data, FS, length(data) / FS);
decoded= [];
 for( k=1: length(data) / FS)
    col = data_matrix(:,k);
    info = (1/FS).*fft(col,FS);
    demod = [info(1:D/2); info(FS-((D/2)-1):FS)];
    decoded = [decoded; demod];
 end
 
 
 scatterplot(decoded)


