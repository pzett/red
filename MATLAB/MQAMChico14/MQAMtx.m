%MQAM

%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');
%Initialize variables
fs=44100; %Sampling frequency
levels = 2;
gb_length=60; %in number of symbols
ts_length=400; %in number of symbols
Nb=10000; %Number of bits to transmit
A= 2; %amplitude to control distance between points in const.
ts = randint(ts_length*2*levels,1,2);
gb = zeros(gb_length*2*levels,1);
data = randint(Nb,1,2);


left = rem(Nb+(ts_length+gb_length)*2*levels,2*levels)

bit_stream = [gb' ts' data' (zeros(2*levels-left,1))'];
L=length(bit_stream);

% n_bit=5;
% n_sym=n_bit*2*levels;
n_sym=8;
%n_bit = n_sym/(2*levels);
Ts=n_sym/fs;

f1=fs/5;
symbol=ones(1,n_sym);

mx=[];my=[];

x=0;
y=0;

%
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
    
    mx=[mx x];
    my=[my y];
    
    
end

v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs);

mconst = mx + my*1i;


qam=[];
win=hann(n_sym)';
%win=ones(1,n_sym);
for(k=1:length(bit_stream)/(2*levels))
    qam=[qam win.*(real(mconst((k-1)*n_sym+1:k*n_sym)).*cos(f1*v)-imag(mconst((k-1)*n_sym+1:k*n_sym)).*sin(f1*v))];
end

mconst_ts=mconst(gb_length*n_sym+1:n_sym:n_sym*(gb_length+ts_length));

ts_mod=qam(gb_length*n_sym+1:(gb_length+ts_length)*n_sym);



% span = 5;        % Filter span in symbols
% rolloff = 0.22;   % Roloff factor of filter
% %rrcFilter = rcosdesign(rolloff, span, n_sym);
% rrcFilter=root_raised_cosine(n_sym,rolloff,span);
% qam = upfirdn(qam, rrcFilter, 1, 1);
% pause
% plot(qam)
% length(qam)


scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Constellation before sending');

mod_signal=qam/(max(abs(qam)+0.001));

ts_mod=ts_mod/(max(abs(ts_mod)+0.001));

wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('MQAM.mat','Nb','levels','f1','data','v','ts_length','gb_length','A','n_sym','mod_signal');
save('ts_mod.mat','ts_mod','mconst_ts','ts')
mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length)


