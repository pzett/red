%OFDM

%Set up variables and workspace.
addpath('./functions/')
close all;
clear;
clc;
fclose('all');
%Initialize variables


fs=44100; %Sampling frequency
pilot = 0; % use pilots in the middle of transmission?
use_menu = 0;


levels = 3; %numbers of levels
A = 1; % constellation amplitude, does not work
FS = 2048; % length of FFT/IFFT
fc = 14000; % carrier frequency
P = 5; %length of prefix
S = 1; %length of suffix
Nc = 64; %number of active subcarriers
high = 512;
if(use_menu);
    choice = menu('Choose an option for TX','Random','File');
    file=choice-1;
else
    file = 0;
end
pilot_int = 12*Nc*2*levels; %(in bits) how many bits should be sent before pilot insertion
ts_pilot_length = 6*Nc; %(in symbols) pilot length to reestimate the channel

ts_length=12*Nc; % (in symbols) length of training sequence
gb_length=4*Nc; % (in symbols) length of guard band

if(mod(ts_pilot_length,2*levels) ~= 0 ); disp('Choose a pilot length multiple of 2*levels'); pause; end

if(file)
    [filename,pathname,filterindex] = uigetfile('*.*','Pick a file');
    if(filterindex==0); error('You must choose a file !'); end;
    str =[pathname,filename];
    data_sent = bytestobits(str);
    if(mod(length(data_sent),Nc) ~= 0 )
        data_sent = [data_sent  zeros(1,Nc-mod(length(data_sent),Nc))]';
        fprintf('The file has %g bytes\n',length(data_sent)/8);
    end
    Nb = length(data_sent);
else
    Nb=50*FS;        %Number of bits to be transmitted
    data_sent = randint(Nb,1,2); % generate random data
end

ts = randint(ts_length*2*levels,1,2); % generate training sequence
gb = randint(gb_length*2*levels,1,2); % generate guard band


left = rem(length(data_sent)+(ts_length+gb_length)*2*levels,2*levels);

if(pilot == 1) % if pilots are used, they must be inserted in the data.
    no_pilots = floor(Nb/pilot_int) %number of pilots in the middle of txmission
    if(no_pilots > 0)
        %use training sequence
        ts_pilot = ts(1:ts_pilot_length*2*levels); %generate pilots samples from training sequence.
        data_temp = data_sent;
        data_sent_pilot = [];
        for(k=1:no_pilots) %merge data with pilots
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


bit_stream = [gb' ts' data_sent_pilot' gb']; % merge the data
L=length(bit_stream); %raw data length

%initialize variables and map into constellation
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

mconst = mx2 + 1i*my2; % resulting constellation

if(mod(length(mconst),Nc) ~= 0)
    mconst = [mconst (1+1i)*ones(Nc-mod(length(mconst),Nc),1)']; %fill with symbols till Nc
end

mconst_ts = mconst(gb_length+1:gb_length+ts_length); %save training sequence constellation

%initialize OFDM modulation

data_OFDM = modulate_OFDM(mconst,Nc,FS,P,S);
%data_OFDM = modulate_OFDM_asym(mconst,Nc,FS,P,S,512);
%data_OFDM = OFDMmod_window(unmod_data,P,S); % do the fft and insert cyclic prefix


%upconvert to carrier frequency
t = 0 : 1/fs : (length(data_OFDM)-1)/fs;
up_signal = real(transpose(data_OFDM).*exp(1i*2*pi*fc*t)); % samples must be real


% segment = up_signal(200:400); tt = 0 : 1/fs : (length(segment)-1)/fs;
% plot(tt,segment); title('Segment of transmitted signal (OFDM) in time'); xlabel('time'); ylabel('Amplitude');
figure(1)
subplot(211)
pwelch(up_signal,[],[],[],fs); title('PSD of transmitted signal (OFDM)')
hold on
%normalize signals to amplitude 1
mod_signal=up_signal/(max(abs(up_signal)+0.001));
ts_mod = up_signal(gb_length/Nc*(FS+S+P)+1:gb_length/Nc*(FS+S+P)+(FS+S+P)*ts_length/Nc); %save ts to synchronize in the receiver
ts_mod=ts_mod/(max(abs(ts_mod)+0.001));

audio_signal = get_audio('gottheme.wav',length(mod_signal));

total = mod_signal + audio_signal;
total = total / max(abs(total));
figure
pwelch(total,[],[],[],fs)
mod_signal = total;


if(mod(gb_length,Nc) || mod(ts_length,Nc)); disp('gb or ts length must be divisable by Nc!!!'); end
%wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',total*(2^15-1));
copy_file_to_all('test_signal.dat');
%copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('OFDM.mat','Nb','levels','fc','data_sent','ts_length','gb_length','A','mod_signal','P','S','Nc','FS','pilot','pilot_int','ts_pilot_length','high','file');
save('ts_mod.mat','ts_mod','mconst_ts','ts','ts_pilot' )
mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length);
fprintf('Estimated effective rate is %g bps \n', Nb/mod_signal_length);


% ts=[];
% for(k=1:ts_length)
%     if(mod(k,2) == 0); ts = [ts; zeros(2*levels,1)];
%     else
%         ts = [ts; ones(2*levels,1)];
%     end
% end
% length(ts)