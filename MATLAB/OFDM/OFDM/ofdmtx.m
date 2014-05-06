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
FS = 1024;
fc = fs/4;
P = 20;
S = 2;
Nc =64;

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

mconst_ts = mconst(gb_length+1:gb_length+ts_length);

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

pwelch(up_signal)

mod_signal=up_signal/(max(abs(up_signal)+0.001));
ts_mod = up_signal(gb_length/Nc*(FS+S+P)+1:gb_length/Nc*(FS+S+P)+(FS+S+P)*ts_length/Nc);
ts_mod=ts_mod/(max(abs(ts_mod)+0.001));


wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('MQAM.mat','Nb','levels','fc','data','ts_length','gb_length','A','mod_signal','P','S','Nc','FS');
save('ts_mod.mat','ts_mod','mconst_ts','ts')
mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length)