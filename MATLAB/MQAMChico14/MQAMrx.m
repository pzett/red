%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');

load('MQAM.mat')
load('ts_mod.mat')
k1=1;

%n_sym=n_bit*2*levels*k1;
fs=44100;

Ts=n_sym/fs;
%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename); %grab log data
r=extract_sound_from_log_data(log_data); %extract sound from log data.
%plot(r)
%
% load('r.mat')
% plot(r)
% r = wavread('mod_signal.wav');
%
% 
% rxFiltSignal = upfirdn(r,rrcFilter,1,1);   % Downsample and filter
% r = rxFiltSignal(span+1:end-span);                       % Account for delay
% r=conv(fliplr(rrcFilter),r);
% r=r';
% length(r)
% pause
% plot(r)

r=r';
[t_samp ref]=synch(r,ts_mod,n_sym/k1);
expected_start=gb_length*n_sym

r=r(t_samp:end);
figure(1)
plot(r(1:2000))
%r = interpft(r,k1*length(r));
Vnx=[];
Vny=[];


figure(2)
subplot(2,2,1)
pwelch(mod_signal)
title('Transmitted signal')
subplot(2,2,2)
pwelch(r)
title('Received signal')

% Demodulation of received signal
for(k=1:(length(data))/(2*levels)+ts_length)
Vnx=[Vnx r((k-1)*n_sym+1:k*n_sym).*cos(f1*v)];
Vny=[Vny r((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v)];
end
subplot(2,2,3)
pwelch(Vnx)
title('Received signal after x')

 
%   Hd=lpf(5,1000);
%  Hx=2.*filter(Hd,Vnx);
%  Hy=2.*filter(Hd,Vny);
%   Hx=2.*filter(Hd,Vnx);
%   Hy=2.*filter(Hd,Vny);

% sos = zp2sos(b,a,q);
% fvtool(sos,'Analysis','freq')
   [b,a]=butter(2,0.18,'low'); 
   Hx=2.*filter(b,a,Vnx);
   Hy=2.*filter(b,a,Vny);
   
   subplot(2,2,4)
   pwelch(Hx)
   title('Rx´d signal after LPF')
   
   figure(3)
   [h,w] = freqz(b,a,2001);
   subplot(1,2,1)
   plot(w/pi,20*log10(abs(h)))
   [phi,w] = phasez(b,a,2001);
    subplot(1,2,2)
   plot(w/pi,phi)
 
set(gca,'ylim',[-100 20],'xtick',0:.5:2)
xlabel 'Normalized Frequency (\times\pi rad/sample)'
ylabel 'Magnitude (dB)'

% % Filter
%  
% % Design filter with least-squares method
% N     = 9;           % Order
% Fpass = 4000;         % Passband Frequency
% Fstop = 2*f1 - 1/(2*Ts);  % Stopband Frequency
% Wpass = 1;            % Passband Weight
% Wstop = 1;            % Stopband Weight
%  
% % Calculate the coefficients using the FIRLS function.
% b  = firls(N, [0 Fpass Fstop fs/2]/(fs/2), [1 1 0 0], [Wpass Wstop]);
%  
% % Filtering
% Hx = filter(b, 1, Vnx);
% Hy = filter(b, 1, Vny);


ML=length(Hx);
Hx=Hx/ref;
Hy=Hy/ref;


dif_length_after_lpf = length(Hx)-length(Vnx)
margin=10;
r_filt=[];
for(k=1:n_sym*(ts_length+2*margin))
    r_aux= Hx(k) + Hy(k)*1i;
    r_filt = [r_filt r_aux];
end

n_samp =synch2(r_filt(1:(ts_length+margin)*n_sym),mconst_ts,n_sym)

mconst=[];
for m=n_samp:n_sym:ML
  
    Haux = Hx(m) + Hy(m)*1i;
    mconst = [mconst Haux];
   
end

scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Received Constellation');

%[t_samp ref]=synch(r(1:n_sym*(length_ts+length_gb+20),mod_ts);



[phihat ref]=phase_estimation(mconst,mconst_ts)

Nt=length(mconst)*2*levels;


batch_length=floor(0.1/Ts);
left=mod(length(mconst),batch_length)

mdem=[];
mconstdem=[];
ref2=1;
for(k=1:floor(length(mconst)/batch_length))
    mconst_phi = mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat) / (ref*ref2);
    mconstdem =[mconstdem mconst_phi]; 
     
   % scatterplot(mconst_phi)
    %mconst_phi = mconst * exp(-1i*phihat) / ref;
   % scatterplot(mconst_phi),grid,xlabel('I'),ylabel('Q'),title('Received Constellation');
     
    for q=1:length(mconst_phi)
        Hx(q)=real(mconst_phi(q));
        Hy(q)=imag(mconst_phi(q));
    end
    
    % Hx=
    % Hy=imag(mconst_phi);





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

if(mod(length(mdem),batch_length)==0)
        demconst=demod(mdem((k-1)*batch_length*2*levels+1:k*batch_length*2*levels),levels,A);
        [theta ref2]=offset_estimation(mconst_phi,demconst)
        phihat=phihat+theta;
      % ref2=1;
        end
end

k=k+1
length(mconst((k-1)*batch_length+1:end))
mconst_phi = mconst((k-1)*batch_length+1:end) * exp(-1i*phihat) / (ref*ref2);
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


test =[ts; data];
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

scatterplot(mconstdem),grid,xlabel('I'),ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
errors = sum(data(1:length(decoded))' ~= decoded  )
 
 BER = errors / length(test)* 100
 R=2*levels / Ts
