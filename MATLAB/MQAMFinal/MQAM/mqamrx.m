%% OFDM Functions to transfer files between two Android devices
%% Receiver Side
%Author : Red Group - Francisco Rosario (frosario@kth.se)
%This script retrieves the latest data from the phone and processes it.
% The training sequence and MQAM parameters are loaded from .mat files
% created by the transmitter.
% this is to be used with mqamtx
% There is an option for looping the parameters that lead to the best
% performance, since this was the system implemented
%Set up variables and workspace.
addpath('./functions/');
close all;
clear;
clc;
fclose('all');

load('MQAM.mat')
load('ts_mod.mat')
fs=44100;
Ts=n_sym/fs;
loops=0;
plotting=1;

if(loops)
    fc = 2491:1:2493;
    order=12:1:14;
    eq_g=5.2:0.2:6;
    alfa = 2.5:0.05:2.6;
    t_block = [0.01 0.02];
    fchard=10500:500:12000;
else
    fc=2491; % cutoff frequency of LPF
    order=12; % order of the LPF filter
    eq_g=5.2; % equalizer gain
    alfa =2.5; % % gaussian window parameters
    t_block = 0.02; % block in which frequency offset does not make difference
    fchard = 11000; % cut off frequency for second low pass filter
end

% Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename) %grab log data
ro=extract_sound_from_log_data(log_data); %extract sound from log data.
no_iterations = length(fc)*length(order)*length(eq_g)*length(alfa)*length(t_block)*length(fchard);
min_var=1e6;


tic
for(k_fc=1:length(fc))
    for(k_o=1:length(order))
        for(k_eq=1:length(eq_g))
            for(k_alfa=1:length(alfa))
                for(k_t=1:length(t_block))
                    for(k_fchard=1:length(fchard))
                        close all
                        
                        
                        r=peakEQ(ro,eq_g(k_eq))'; %use equalizer
                        %r=ro; % don't use equalizer
                        if(plotting)
                            figure(1)
                            plot(r);
                        end
                        
                        [t_samp ref]=synch(r,ts_mod,n_sym,plotting); % find sampling time
                        
                        r=r';
                        r=r(t_samp:end); %crop guard band
                        
                        if(plotting)
                            figure(2)
                            subplot(2,2,1)
                            pwelch(mod_signal)
                            title('Transmitted signal')
                            subplot(2,2,2)
                            pwelch(r)
                            title('Received signal')
                        end
                        
                        if(continuous) %correlate received signal
                            t=0:1/fs:length(r)/fs-1/fs;
                            Vnx=r.*cos(2*pi*f1*t);
                            Vny=-r.*sin(2*pi*f1*t);
                            Vnx=Vnx(1:n_sym*(length(data)/(2*levels)+ts_length+20));
                            Vny=Vny(1:n_sym*(length(data)/(2*levels)+ts_length+20));
                        else
                            %                             Vnx=[];
                            %                             Vny=[];
                            Vnx = zeros(n_sym*floor(length(data) / (2*levels)+ts_length+100),1);
                            Vny = zeros(n_sym*floor(length(data) / (2*levels)+ts_length+100),1);
                            v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs); %vector containing data for 1 period.
                            % Demodulation of received signal
                            position = 0;
                            for(k=1:(length(data))/(2*levels)+ts_length+100)
                                auxx = r((k-1)*n_sym+1:k*n_sym).*cos(f1*v);
                                auxy = r((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v);
                                Vnx(position+1:position+n_sym)=auxx;
                                Vny(position+1:position+n_sym)=auxy;
                                position = position + n_sym;
                                %                                 Vnx=[Vnx r((k-1)*n_sym+1:k*n_sym).*cos(f1*v)];
                                %                                 Vny=[Vny r((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v)];
                            end
                        end
                        
                        Hd=lpf(order(k_o),fc(k_fc),alfa(k_alfa)); %generate low pass filter
                        %save coefficients to txt file ?
                        %saveD_to_file('lpf.txt',Hd.numerator,length(Hd.numerator))
                        
                        Hx=2.*filter(Hd,Vnx); %LPF
                        Hy=2.*filter(Hd,Vny); %LPF
                        %second, higher order LPF
                        %Hd=lpfhard(fchard(k_fchard));
                        %Hx=2.*filter(Hd,Hx);
                        %Hy=2.*filter(Hd,Hy);
                        
                        ML = length (Hx);
                        
                        
                        if(plotting)
                            subplot(2,2,3)
                            pwelch(Vnx)
                            title('Received signal after x')
                            subplot(2,2,4)
                            pwelch(Hx)
                            title('Rx?d signal after LPF')
                            xlabel 'Normalized Frequency (\times\pi rad/sample)'
                            ylabel 'Magnitude (dB)'
                        end
                        
                        
                        
                        margin=100; % margin to find symbol wise sampling time
                        r_filt=[];
                        for(k=1:n_sym*(ts_length+2*margin))
                            r_aux= Hx(k) + Hy(k)*1i; %map into constellation
                            r_filt = [r_filt r_aux];
                        end
                        
                        n_samp = synch2(r_filt(1:(ts_length+2*margin)*n_sym),mconst_ts,n_sym); % find symbol wise best samplig time
                        
                        mconst=[];
                        
                        for m=n_samp:n_sym:ML %upsample !
                            Haux = Hx(m) + Hy(m)*1i;
                            mconst = [mconst Haux];
                        end
                        
                        if(plotting) scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Received Constellation'); end
                        
                        [phihat ref ref_re ref_im]=phase_estimation(mconst,mconst_ts); %estimate initial phase and amplitude
                        
                        
                        batch_length=floor(t_block(k_t)/Ts); % block length to correct frequency offset
%                         mdem=[];
                        mconstdem=[];
                        ref2=1; % variable to keep track of variations in the amplitude
                        mdem = zeros(length(mconst)*2*levels,1);
                        variance=0; position = 0;
                        for(k=1:floor(length(mconst)/batch_length))
                            mconst_phi = real(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2) + 1i*imag(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2);
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
                              %  mdem=[mdem fliplr(sym)];
                                
                                mdem(position+1:position+2*levels) = fliplr(sym);
                                position = position + 2*levels;
                                aux=demod(fliplr(sym),levels,A);
                                aux=(Hx(m)-real(aux)).^2+(Hy(m)-imag(aux)).^2;
                                variance=variance+aux;
                            end
                            
                            if(mod(position,batch_length)==0)
                                demconst=demod(mdem((k-1)*batch_length*2*levels+1:k*batch_length*2*levels),levels,A);
                                [theta ref2]=offset_estimation(mconst_phi,demconst); % estimate frequency offset
                                phihat=phihat+theta; % update phase estimation
                                ref2=1; % channel is time invariant in amplitude
                            end
                        end
                        
                        %compute last batch
                        
                        k=k+1;
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
                            mdem(position+1:position+2*levels) = fliplr(sym);
                            position = position + 2*levels;
%                             mdem=[mdem fliplr(sym)];
                            aux=demod(fliplr(sym),levels,A);
                            aux=(Hx(m)-real(aux)).^2+(Hy(m)-imag(aux)).^2;
                            variance=variance+aux;
                        end
                        
                        test =[ts; data];
                        decoded=mdem';
                        
                        
                        %process bits. compare with transmitted. see if
                        %the parameters were better than previous. scatter
                        %constellation
                        scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
                        if(length(decoded)>=length(test))
                            decoded=decoded(1:length(test));
                            if(plotting) stem(test' ~= decoded); end
                            errors = sum(test(length(ts)+1:end)' ~= decoded(length(ts)+1:end));
                            BER = errors / length(test(length(ts)+1:end)) * 100
                            if(BER==0)
                                if(variance/length(test(length(ts)+1:end))<min_var)
                                    scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
                                    min_var=variance/length(test(length(ts)+1:end));
                                    
                                    best_fc=fc(k_fc);
                                    best_gain=eq_g(k_eq);
                                    best_o=order(k_o);
                                    % retrieve_coeffs(Hd);
                                    best_t = t_block(k_t);
                                    best_alfa = alfa(k_alfa);
                                    best_variance = variance;
                                    best_fchard = fchard(k_fchard);
                                    % saveD_to_file('min_var.txt',[min_var best_fc best_gain best_o best_t best_alfa best_fchard],7);
                                end
                                
                            end
                            
                        end
                        no_iterations=no_iterations-1
                    end
                end
            end
        end
    end
end
R = 2 * levels / Ts
%uncomment to disply best parameters
% best_fc = best_fc
% best_o = best_o
% best_gain = best_gain
% best_alfa = best_alfa
% best_t = best_t
% min_var = min_var
% best_variance = best_variance
% best_fchard = best_fchard

toc
