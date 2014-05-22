%MQAM

%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');
%Initialize variables


fs=44100; %Sampling frequency

%Set up determining variables


levels = 3;
Nb=10000*8; %Number of bits to transmit
f1=fs/4;
%f1=10000;
n_sym=8;
Ts=n_sym/fs;
ts_length=200; %in number of symbols
gb_length=540; %in number of symbols
alfa = 2.5;
A=1; %amplitude to control distance between points in const -> does not work

continuous=0;
windowc=0; %choose which window to apply 0 -> rect/hann 1-> RRC
%Choose rectangular or hanning
% win=hann(n_sym)';
%
% win=bartlett(n_sym)' ;
% win=hamming(n_sym)';
%win=taylorwin(n_sym)';
%win=rcosdesign(0.25,2,8)
%win=gausswin(n_sym,alfa)';
win=ones(n_sym,1)';
span = 2;        % Filter span in symbols
rolloff = 0.22;   % Roloff factor of filter


ts = randint(ts_length*2*levels,1,2);
gb = randint(gb_length*2*levels,1,2);%zeros(gb_length*2*levels,1);
data = randint(Nb,1,2);
% ts=load_ts_from_file('ts_test.txt',levels); 
% gb=load_gb_from_file('gb_test.txt',levels);
% data=load_data_from_file('data_test.txt',levels);
%save_to_file(gb,ts,data,levels);
left = rem(Nb+(ts_length+gb_length)*2*levels,2*levels);
bit_stream = [gb' ts' data' (zeros(2*levels-left,1))' gb'];
L=length(bit_stream);


%Generate auxiliar variables to compute tx_signal with window and RRC
symbol=ones(1,n_sym);
symbol2=ones(1,1);
mx=[]; my=[];
mx2=[]; my2=[];

x=0;
y=0;
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
    
    x=xi*symbol;
    y=yi*symbol;
    x2=xi*symbol2;
    y2=yi*symbol2;
        
    mx=[mx x];
    my=[my y];
    mx2=[mx2 x2];
    my2=[my2 y2];
end

%Design rrcFilter
% rrcFilter = rcosdesign(rolloff, span, n_sym);
% mxu = upfirdn(mx2, rrcFilter,n_sym);
% myu = upfirdn(my2, rrcFilter,n_sym);
% t=0:1/fs:length(mxu)/fs-1/fs;
% qamrc=mxu.*cos(2*pi*f1*t)-myu.*sin(2*f1*pi*t);

mconst = mx + my*1i; %Constellation of sent dats
if(continuous==0)
v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs); %vector containing data for 1 period.
qam=[];
for(k=1:length(bit_stream)/(2*levels))
    qam=[qam win.*(real(mconst((k-1)*n_sym+1:k*n_sym)).*cos(f1*v)-imag(mconst((k-1)*n_sym+1:k*n_sym)).*sin(f1*v))];
   
end

else
t=0:1/fs:length(mconst)/fs-1/fs; 
qam=real(mconst).*cos(2*pi*f1*t)-imag(mconst).*sin(2*f1*pi*t);
for(k=1:length(bit_stream)/(2*levels))
    qam((k-1)*n_sym+1:k*n_sym)=win.*qam((k-1)*n_sym+1:k*n_sym);
end
end

mconst_ts=mconst(gb_length*n_sym+1:n_sym:n_sym*(gb_length+ts_length));
if(windowc==0)%rectangular/hanning window
ts_mod=qam((gb_length*n_sym+1:(gb_length+ts_length)*n_sym));%retrieve modulated training sequence
else%RRC window
ts_modrc=qamrc(gb_length*n_sym+1:(gb_length+ts_length)*n_sym); %this is not correct, rrc causes span
end

figure(3)
%subplot(1,2,1)
pwelch(qam,[],[],[],fs);

%pwelch(qamrc)

scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Constellation before sending');

if(windowc==1) %RRC window
    mod_signal=qamrc/(max(abs(qamrc)+0.001));
    ts_mod=ts_modrc/(max(abs(ts_modrc)+0.001));
else %rectangular/hanning window window
   mod_signal=qam/(max(abs(qam)+0.001));
   ts_mod=ts_mod/(max(abs(ts_mod)+0.001));
end


wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*2^14)
copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );
save('MQAM.mat','Nb','levels','f1','data','span','ts_length','gb_length','A','n_sym','mod_signal','continuous','qam');
save('ts_mod.mat','ts_mod','mconst_ts','ts')
mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length)
fprintf('Effective Rate : %g bps',Nb/mod_signal_length);


