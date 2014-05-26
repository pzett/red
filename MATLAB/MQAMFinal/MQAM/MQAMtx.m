%% MQAM Functions to transfer files between two Android devices
%% Transmitter Side
%Author : Red Group - Francisco Rosario (frosario@kth.se)
%This script creates and modulates binary data into complex baseband symbols and
%creates the corresponding signal. It then uploads the file in format of
%shorts to the connected devices.
%The binary source must be a random one. (to see a file choosing system, please see OFDM implementation)
%This function is to be used with mqamrx

%Set up variables and workspace.
addpath('./functions/');
close all;
clear;
clc;
fclose('all');
%Initialize variables


fs=44100; %Sampling frequency

%Set up determining variables
pilot = 1;
pilot_int = 5500; % (in symbols)
pilot_len = 5;

levels = 3; % size of constellation
Nb=80000*8; %Number of bits to transmit
f1=fs/4; % carrier frequency

iv = 1;

n_sym=8; % number of samples per symbol
Ts=n_sym/fs; % symbol period

ts_length=220; %in number of symbols
gb_length=540; %in number of symbols

alfa = 1.9; % gaussian window parameter
A=1; %amplitude to control distance between points in const -> does not work

continuous=0;
%Choose a window
% win=hann(n_sym)';
% win=bartlett(n_sym)' ;
% win=hamming(n_sym)';
%win=taylorwin(n_sym)';
win=gausswin(n_sym,alfa)';
%win=ones(n_sym,1)';

file = create_menu(1);

%Generate random data
% ts = randint(ts_length*2*levels,1,2);
% gb = randint(gb_length*2*levels,1,2);
% data = randint(Nb,1,2);
[gb,gb_end,ts,data,Nb] = generate_data(gb_length,ts_length,Nb,levels,file,iv);
%save_to_file(gb,ts,data,levels);
data_sent = data;
[data,ts_pilot] = generate_pilots(data,pilot_int,pilot_len,Nb,pilot,levels);

left = rem(Nb+(ts_length+gb_length)*2*levels,2*levels);
bit_stream = [gb' ts' data' gb']; %merge bits

if(mod(length(bit_stream),2*levels) ~= 0 )
    fprintf('Added %g bits to fill constellation symbol\n', 2*levels-mod(length(bit_stream),2*levels));
    bit_stream = [bit_stream  zeros(1,2*levels-mod(length(bit_stream),2*levels))];    
end
L=length(bit_stream);
%Generate auxiliar variables to compute tx_signal with window and RRC
symbol=ones(1,n_sym);
%mx=[]; my=[];
mx = zeros(L/(2*levels)*n_sym,1);
my = zeros(L/(2*levels)*n_sym,1);
x=0;
y=0;
position = 0;
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
    
    x=xi*symbol;
    y=yi*symbol;
       
    mx(position+1:position+n_sym)=x;
    my(position+1:position+n_sym)=y;
    position = position + n_sym;
        
end

mconst = transpose(mx + my*1i); %Constellation of sent data
if(continuous==0) % how will the time vector be created?
    v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs); %vector containing data for 1 period.
    qam=zeros(length(bit_stream)/(2*levels)*n_sym,1)';
    position = 0;
    for(k=1:length(bit_stream)/(2*levels))
        aux = win.*(real(mconst((k-1)*n_sym+1:k*n_sym)).*cos(f1*v)-imag(mconst((k-1)*n_sym+1:k*n_sym)).*sin(f1*v));
       % qam=[qam win.*(real(mconst((k-1)*n_sym+1:k*n_sym)).*cos(f1*v)-imag(mconst((k-1)*n_sym+1:k*n_sym)).*sin(f1*v))];
        qam(position+1:position+n_sym) = aux;
        position = position + n_sym; 
    end
else
    t=0:1/fs:length(mconst)/fs-1/fs;
    qam=real(mconst).*cos(2*pi*f1*t)-imag(mconst).*sin(2*f1*pi*t);
    for(k=1:length(bit_stream)/(2*levels))
        qam((k-1)*n_sym+1:k*n_sym)=win.*qam((k-1)*n_sym+1:k*n_sym);
    end
end

mconst_ts=mconst(gb_length*n_sym+1:n_sym:n_sym*(gb_length+ts_length));
ts_mod=qam((gb_length*n_sym+1:(gb_length+ts_length)*n_sym));%retrieve modulated training sequence
pilot_const = demod(ts_pilot,levels,A); 

figure(3)
pwelch(qam,[],[],[],fs);

scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Constellation before sending');


mod_signal=qam/(max(abs(qam)+0.001));
ts_mod=ts_mod/(max(abs(ts_mod)+0.001));



wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('MQAM.mat','Nb','levels','f1','data','ts_length','gb_length','A','n_sym','mod_signal','continuous','qam','pilot_const','pilot_int','pilot_len','pilot','data_sent');
save('ts_mod.mat','ts_mod','mconst_ts','ts')
mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length)
fprintf('Effective Rate : %g bps\n',Nb/mod_signal_length);


