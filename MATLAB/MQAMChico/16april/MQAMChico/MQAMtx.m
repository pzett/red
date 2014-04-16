%MQAM

%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');
%Initialize variables
fs=44100; %Sampling frequency
ts_length=500; %in number of symbols



Nb=7000; %Number of bits to transmit
levels = 2;
span = 10;        % Filter span in symbols
rolloff = 0.22;   % Roloff factor of filter
f1=fs/5;
n_sym=10;
gb_length=40; %in number of symbols
windowc=0 %choose which window to apply 0 -> rect/hann 1-> RRC



A=2; %amplitude to control distance between points in const ->does not work

ts = randint(ts_length*2*levels,1,2);
gb = zeros(gb_length*2*levels,1);
data = randint(Nb,1,2);

left = rem(Nb+(ts_length+gb_length)*2*levels,2*levels)

bit_stream = [gb' ts' data' (zeros(2*levels-left,1))'];
L=length(bit_stream);


% n_sym=n_bit*2*levels;
%n_bit = n_sym/(2*levels);

Ts=n_sym/fs;




% symbol=ones(1,n_sym);
symbol=ones(1,n_sym);
symbol2=ones(1,1);
mx=[]; my=[];
mx2=[]; my2=[];

x=0;
y=0;
x2=0;
y2=0;
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
    x2=xi*symbol2;
    y2=yi*symbol2;
    
    
    mx=[mx x];
    my=[my y];
    mx2=[mx2 x2];
    my2=[my2 y2];
    
end



v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs);
mconst = mx + my*1i;



rrcFilter = rcosdesign(rolloff, span, n_sym);
mxu = upfirdn(mx2, rrcFilter,n_sym);
myu = upfirdn(my2, rrcFilter,n_sym);
% mxu=mxu(span*n_sym:end);
% myu=myu(span*n_sym:end);
t=0:1/fs:length(mxu)/fs-1/fs;
qamrc=mxu.*cos(2*pi*f1*t)-myu.*sin(2*f1*pi*t);
% subplot(1,2,1)
% plot(mxu(1:500))
% subplot(1,2,2)
% plot(mx(1:500))
% pause

%Choose rectangular or hanning
win=hann(n_sym)';
%win=ones(1,n_sym);
qam=[];
for(k=1:length(bit_stream)/(2*levels))
    qam=[qam win.*(real(mconst((k-1)*n_sym+1:k*n_sym)).*cos(f1*v)-imag(mconst((k-1)*n_sym+1:k*n_sym)).*sin(f1*v))];
end

mconst_ts=mconst(gb_length*n_sym+1:n_sym:n_sym*(gb_length+ts_length));
%mconst_ts2=mx2(gb_length+1:ts_length+gb_length)+my2(gb_length+1:ts_length+gb_length)*1i;


if(windowc==0)
ts_mod=qam((gb_length*n_sym+1:(gb_length+ts_length)*n_sym));
else
ts_modrc=qamrc(gb_length*n_sym+1:(gb_length+ts_length)*n_sym);
end

figure(3)
subplot(1,2,1)
pwelch(qam)
subplot(1,2,2)
pwelch(qamrc)

scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Constellation before sending');

figure(4)
plot(qamrc(span*n_sym-1:2000))

if(windowc==1)
    mod_signal=qamrc/(max(abs(qamrc)+0.001));
    ts_mod=ts_modrc/(max(abs(ts_modrc)+0.001));
else
   mod_signal=qam/(max(abs(qam)+0.001));
   ts_mod=ts_mod/(max(abs(ts_mod)+0.001));
end


wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('MQAM.mat','Nb','levels','f1','data','span','v','ts_length','gb_length','A','n_sym','mod_signal','rrcFilter');
save('ts_mod.mat','ts_mod','mconst_ts','ts')
mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length)


