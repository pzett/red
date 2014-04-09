%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');


load('MQAM.mat')
load('ts_mod.mat')
n_sym=n_bit*2*levels;
%Pull out info from sensor
% names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
% filename = char(names.filenames(end)); % Char converts cell to string
% copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
% log_data=get_log_data_from_FrameWork(filename); %grab log data
% r=extract_sound_from_log_data(log_data); %extract sound from log data.
r = wavread('mod_signal.wav');
r=r';
stem(ts_mod)

[t_samp ref]=synch(r(1:n_sym*(ts_length+gb_length+20)),ts_mod)

r=r(t_samp:end);


Vnx=[];
Vny=[];
% Demodulation of received signal
for(k=1:(length(data))/(2*levels)-gb_length+ts_length)
Vnx=[Vnx r((k-1)*n_sym+1:k*n_sym).*cos(f1*v)];
Vny=[Vny r((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v)];
end


[b,a]=butter(2,0.04);
Hx=2.*filter(b,a,Vnx);
Hy=2.*filter(b,a,Vny);
ML=length(Hx);
Hx=Hx/ref;
Hy=Hy/ref;

mconst=[];
for m=n_bit:2*levels*n_bit:ML
    Haux = Hx(m) + Hy(m)*1i;
    mconst = [mconst Haux];
end

scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Received Constellation');

%[t_samp ref]=synch(r(1:n_sym*(length_ts+length_gb+20),mod_ts);

phihat=phase_estimation(mconst,mconst_ts)

mconst_phi = mconst * exp(-1i*phihat);




mdem=[];
for m=n_bit:2*levels*n_bit:ML
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
        th_y = th_y + i_y*(2^(levels-n));
        th_x =  th_x + i_x*(2^(levels-n));
    end
   
    mdem=[mdem fliplr(sym)];
end

BER=sum(mdem(1:400)'~=[ts ;data(1:200)])/Nb*100