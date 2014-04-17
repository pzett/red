%Set up variables and workspace.
close all;
clear;
clc;
load('MQAM.mat')
load('ts_mod.mat')

%ts_mod=ts_modrc;
%n_sym=n_bit*2*levels*k1;
fs=44100;
fc = 3700; % LP Cutoff frequency
Ts=n_sym/fs;
%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename); %grab log data
r=extract_sound_from_log_data(log_data); %extract sound from log data.

%Design equalizer
d  = fdesign.parameq('F0,BW,BWp,Gref,G0,GBW,Gp',0.2732,0.15,0.03,0,8,3,5);
Hd = design(d);
r=filter(Hd,r); %filter received with equalizer

%r=conv(r,rrcFilter); %matched filter -> still not working (maybe use
%filter function?





%[t_samp ref]=synch(r,ts_mod,n_sym/k1);

%expected_start=gb_length*n_sym
first_samp=find_threshold(r) %tell where signal starts
ref=1;
r=r';
r=r(first_samp:end); %crop signal

figure(1)
plot(r)
title('Received Signal')

%r = interpft(r,k1*length(r));
Vnx=[];
Vny=[];


figure(2)
subplot(2,2,1)
pwelch(mod_signal)
title('PSD Transmitted signal')
subplot(2,2,2)
pwelch(r)
title('PSD Received signal')


% Demodulation of received signal %NOT BEING USED AT MOMENT
for(k=1:(length(data))/(2*levels)+ts_length)
Vnx=[Vnx r((k-1)*n_sym+1:k*n_sym).*cos(f1*v)];
Vny=[Vny r((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v)];
end


t=0:1/fs:length(r)/fs-1/fs; %define time vector
Vnx2=r.*cos(2*pi*f1*t); %correlate
Vny2=-r.*sin(2*pi*f1*t); %correlate

%crop to data length (no need noise)
margin=50; 
Vnx2=Vnx2(1:n_sym*(length(data)/(2*levels)+ts_length+gb_length+margin));
Vny2=Vny2(1:n_sym*(length(data)/(2*levels)+ts_length+gb_length+margin));

subplot(2,2,3)
pwelch(Vnx2)
title('Received signal after x')
 


%  Hx=2.*filter(Hd,Vnx);
%  Hy=2.*filter(Hd,Vny);
Hd=lpf(8,fc);
Hx2=2.*filter(Hd,Vnx2);
Hy2=2.*filter(Hd,Vny2);


% sos = zp2sos(b,a,q);
% fvtool(sos,'Analysis','freq')
%    [b,a]=butter(5,0.08 ,'low'); 
%    Hx=2.*filter(b,a,Vnx);
%    Hy=2.*filter(b,a,Vny);


 Hx=Hx2;
 Hy=Hy2;
 subplot(2,2,4)
 pwelch(Hx)
 title('Rx�d signal after LPF')
 xlabel 'Normalized Frequency (\times\pi rad/sample)'
ylabel 'Magnitude (dB)'  
%    figure(3)
%    [h,w] = freqz(b,a,2001);
%    subplot(1,2,1)
%    plot(w/pi,20*log10(abs(h)))
%    [phi,w] = phasez(b,a,2001);
%     subplot(1,2,2)
%    plot(w/pi,phi) 
%set(gca,'ylim',[-100 20],'xtick',0:.5:2)

% Hx=Hx/ref;
% Hy=Hy/ref;

ML=length(Hx);
dif_length_after_lpf = length(Hx2)-length(Vnx2);

margin=100;
r_filt=[];
for(k=1:n_sym*(margin+gb_length+ts_length))
    r_aux= Hx(k) + Hy(k)*1i;
    r_filt = [r_filt r_aux];
end
%synchronize find first sample of training sequence
n_samp =synch2(r_filt(1:end),mconst_ts,n_sym)


mconst=[];
margin=110;
%sample in intervals of n_sym
for m=n_samp:n_sym:n_sym*(length(data)/(2*levels)+ts_length+margin)
    Haux = Hx(m) + Hy(m)*1i;
    mconst = [mconst Haux];
end

scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Received Constellation');

%estimate the phase and gain of channel using Tsequence.
[phihat ref]=phase_estimation(mconst,mconst_ts)

Nt=length(mconst)*2*levels;


batch_length=floor(0.1/Ts); %estimate phase each 0.1 seconds %change if needed
%left=mod(length(mconst),batch_length)


%Estimate transmitted symbols
mdem=[];
mconstdem=[];
ref2=1;
for(k=1:floor(length(mconst)/batch_length)) %Divide into blocks due to phase offset
    %rotate sequence according to last phase estimation and channel gain
    mconst_phi = mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat) / (ref*ref2);
    mconstdem =[mconstdem mconst_phi];
    
    %scatterplot(mconst_phi),grid,xlabel('I'),ylabel('Q'),title('Received Constellation');
    
    for q=1:length(mconst_phi)
        Hx(q)=real(mconst_phi(q));
        Hy(q)=imag(mconst_phi(q));
    end
    
    %do maximum likelihood
    for m=1:length(mconst_phi)
        sym=[];
        th_x=0;th_y=0;
        i_x=0;i_y=0;
        for n=1:levels
            if Hy(m) > th_y %compare with border of decision region
                sym = [sym 0];
                i_y=1;
            else
                sym = [sym 1];
                i_y=-1;
            end
            
            if Hx(m) > th_x
                sym = [sym 0];
                i_x=1;
            else
                sym = [sym 1];
                i_x=-1;
            end
            th_y = th_y + A*i_y*(2^(levels-n));
            th_x =  th_x + A*i_x*(2^(levels-n));
        end
        
        mdem=[mdem fliplr(sym)];
    end
    
    if(mod(length(mdem),batch_length)==0) %if it's end of block -> reestimate phase
        demconst=demod(mdem((k-1)*batch_length*2*levels+1:k*batch_length*2*levels),levels,A);
        [theta ref2]=offset_estimation(mconst_phi,demconst)
        phihat=phihat+theta;
        %ref2=1; %uncomment if channel gain varies with time
    end
end

%compute last block
k=k+1
mconst_phi = mconst((k-1)*batch_length+1:end) * exp(-1i*phihat) / (ref*ref2);
mconstdem =[mconstdem mconst_phi];
for q=1:length(mconst_phi)
    Hx(q)=real(mconst_phi(q));
    Hy(q)=imag(mconst_phi(q));
end



for m=1:length(mconst_phi)
    sym=[];
    th_x=0;th_y=0;
    i_x=0;i_y=0;
    for n=1:levels
        if Hy(m) > th_y
            sym = [sym 0];
            i_y=1;
        else
            sym = [sym 1];
            i_y=-1;
        end
        
        if Hx(m) > th_x
            sym = [sym 0];
            i_x=1;
        else
            sym = [sym 1];
            i_x=-1;
        end
        th_y = th_y + A*i_y*(2^(levels-n));
        th_x =  th_x + A*i_x*(2^(levels-n));
    end
    
    mdem=[mdem fliplr(sym)];
end


test =[ts; data]; %sent data for comparison with decoded
a=length(test) %length of sent data
test=[test; zeros(1,1000*n_sym)']; %add zeros
data=[];
decoded=[];
for(k=1:floor(2*levels*length(mconst)/batch_length))
    decoded=[decoded mdem((k-1)*batch_length+1:k*batch_length)];
    data=[data; test((k-1)*batch_length+1:k*batch_length)];
    %     b_errors = sum(data' ~= decoded  );
    %     b_BER=b_errors / batch_length * 100
end
k=k+1
decoded=[decoded mdem((k-1)*batch_length+1:end)];
data=[data;test((k-1)*batch_length+1:end)];
% b_errors = sum(data' ~= decoded  );
% b_BER= b_errors / batch_length * 100
errors = sum(data(1:length(decoded))' ~= decoded(1:end)  )
BER1_includingTS = errors /length(decoded)* 100
errors = sum(data(ts_length*n_sym:a)' ~= decoded(ts_length*n_sym:a))
BER2 = errors / length(data(ts_length*n_sym:a)) * 100
R=2*levels / Ts
scatterplot(mconstdem(ts_length:end)),grid,xlabel('I'),ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');

%fvtool(Hd)
fclose('all');