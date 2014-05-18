%OFDM

%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');
%Initialize variables


fs=44100; %Sampling frequency

levels = 1;
A = 1;
FS = 2048;
fc = fs/4;
P = 20;
S = 20;
Nc = 512;

ts_length=3*FS;
gb_length=3*FS;
Nb=3*FS;        %Number of bits to transmit
ts = randint(ts_length*2*levels,1,2);
gb = randint(gb_length*2*levels,1,2);%zeros(gb_length*2*levels,1);
data = randint(Nb,1,2);
left = rem(Nb+(ts_length+gb_length)*2*levels,2*levels)
bit_stream = [gb' ts' data'  gb'];
L=length(bit_stream);

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

num_cols=length(mconst)/Nc;
data_matrix = reshape(mconst, Nc, num_cols);
unmod_data=zeros(FS,num_cols);
for (k=1:num_cols)
    info=zeros(FS,1);
    data=data_matrix(:,k);
    D=length(data);
    info(1:(D/2)) = [ data(1:(D/2)).']; %Zero padding
    info((FS-((D/2)-1)):FS) = [ data(((D/2)+1):D).'];
    unmod_data(:,k) = info;
end

data_OFDM = OFDMmod(unmod_data,P,S);
t = 0 : 1/fs : (length(data_OFDM)-1)/fs; 
up_signal = real(transpose(data_OFDM).*exp(1i*2*pi*fc*t));
figure(5)
stem(up_signal(1:200));
figure(1)
subplot(211)
pwelch(real(data_OFDM))
subplot(212)
pwelch(up_signal)
figure(2)
stem(up_signal)
% mod_signal=up_signal/(max(abs(up_signal)+0.001));
ts_mod = up_signal(gb_length/Nc*(FS+S+P)+1:gb_length/Nc*(FS+S+P)+(FS+S+P)*ts_length/Nc);
% ts_mod=ts_mod/(max(abs(ts_mod)+0.001));
length(up_signal)




ro = up_signal;
figure(3)
subplot(211)
t_samp = synch(ro,ts_mod);
r = ro(t_samp:end);

t = 0: 1/fs : (length(r) - 1) /fs;
r=2*exp(-1i*2*pi*fc*t).*r;
% Hd = lpf(20,3/4*fc);
% r = filter (Hd,r);
subplot(212)
pwelch(r)

if(mod(length(r), S+P+FS) ~= 0 )
    r = [r ; zeros(FS+S+P-mod(length(r), S+P+FS),1)];
end
n_cols = length(r)/(S+P+FS);
r_matrix = reshape ( r , S+P+FS,n_cols);
decoded = [];
for(k=1:n_cols)
    data_with_cp = r_matrix(:,k);
    data = [data_with_cp(P+1:end-S)];
    info = fft(data,FS);
    D = Nc;
    demod = [info(1:D/2); info(FS-((D/2)-1):FS)];
    decoded = [decoded; demod];
end

scatterplot(decoded)

errors = sum(transpose((decoded(1:ts_length + Nb / (2*levels))))~=mconst(ts_length+1:end-gb_length) )
