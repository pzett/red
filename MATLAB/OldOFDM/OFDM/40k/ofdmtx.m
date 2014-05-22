%OFDM

%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');
%Initialize variables


fs=44100; %Sampling frequency

levels = 3; %numbers of levels
A = 1; % does not work
FS = 2048; % length of FFT/IFFT
fc = fs/4; % carrier frquency
P = 5; %length of prefix
S = 1; %length of suffix
Nc =512; %number of active subcarriers

pilot = 0; % use pilots in the middle of transmission?

pilot_int = 12*Nc*2*levels; %(in bits) how many bits should be sent before pilot insertion
ts_pilot_length = 6*Nc; %(in symbols) pilot length to reestimate the channel
ts_length=12*Nc; %(in symbols) length of training sequence
gb_length=FS; %(in symbols) length of guard band

if(mod(ts_pilot_length,2*levels) ~= 0 ); disp('Choose a pilot length multiple of 2*levels'); pause; end
Nb=50*FS;        %Number of bits to be transmitted
ts = randint(ts_length*2*levels,1,2); % generate training sequence
gb = randint(gb_length*2*levels,1,2);
data_sent = randint(Nb,1,2);
left = rem(Nb+(ts_length+gb_length)*2*levels,2*levels)

if(pilot == 1)
    no_pilots = floor(Nb/pilot_int)
    if(no_pilots > 0)
        %use training sequence
        ts_pilot = ts(1:ts_pilot_length*2*levels);
        data_temp = data_sent;
        data_sent_pilot = [];
        for(k=1:no_pilots)
            aux = [data_temp((k-1)*pilot_int+1:k*pilot_int); ts_pilot];
            data_sent_pilot = [data_sent_pilot; aux];
        end
        %fill with the rest of bits
        if(k*pilot_int < length(data_temp))
            data_sent_pilot = [data_sent_pilot; data_temp(k*pilot_int+1:end)]; end
    end
else
    data_sent_pilot = data_sent;
    ts_pilot =[];
end


bit_stream = [gb' ts' data_sent_pilot' gb'];
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
    info(1:(D/2)) = [data(1:(D/2)).']; %Zero padding
    info((FS-((D/2)-1)):FS) = [data(((D/2)+1):D).'];
    unmod_data(:,k) = info;
end

data_OFDM = OFDMmod(unmod_data,P,S);
t = 0 : 1/fs : (length(data_OFDM)-1)/fs; 
up_signal = real(transpose(data_OFDM).*exp(1i*2*pi*fc*t));
figure(1)
subplot(211)
segment = up_signal(200:400); tt = 0 : 1/fs : (length(segment)-1)/fs;
plot(tt,segment); title('Segment of transmitted signal in time'); xlabel('time'); ylabel('Amplitude');
subplot(212)
pwelch(up_signal); title('PSD of transmitted signal (OFDM)')

mod_signal=up_signal/(max(abs(up_signal)+0.001));
ts_mod = up_signal(gb_length/Nc*(FS+S+P)+1:gb_length/Nc*(FS+S+P)+(FS+S+P)*ts_length/Nc);
ts_mod=ts_mod/(max(abs(ts_mod)+0.001));


%wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('MQAM.mat','Nb','levels','fc','data_sent','ts_length','gb_length','A','mod_signal','P','S','Nc','FS','pilot','pilot_int','ts_pilot_length');
save('ts_mod.mat','ts_mod','mconst_ts','ts','ts_pilot' )
mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length)