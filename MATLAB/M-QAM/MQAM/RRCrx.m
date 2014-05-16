%Commands to start parfor
%pmode start
%matlabpool open

%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');

load('MQAM.mat')
load('ts_mod.mat')
fs=44100;
Ts=n_sym/fs;
loops=1;
plotting=0;

if(loops)
    fc = 2000:200:4000;
    order=12:2:18;
    eq_g=5.2:0.1:5.4;
    alfa = 2.4:0.1:2.5;
    t_block = [0.01];
else
    fc=2500;
    order=12;
    eq_g=5.2;
    alfa = 2.5;
    t_block = 0.01;
end

% Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename) %grab log data
ro=extract_sound_from_log_data(log_data); %extract sound from log data.
%  ro = load_from_file('rx_signal.txt');
no_iterations = length(fc)*length(order)*length(eq_g)*length(alfa)*length(t_block);
min_var=1e6;
tic
for(k_fc=1:length(fc))
    for(k_o=1:length(order))
        for(k_eq=1:length(eq_g))
            for(k_alfa=1:length(alfa))
                for(k_t=1:length(t_block))
                    close all
                    %             d  = fdesign.parameq('F0,BW,BWp,Gref,G0,GBW,Gp',0.2732,0.15,0.03,0,eq_g(k_eq),3,5);
                    %             Hd = design(d);
                    %             [b,a]=sos2tf(Hd.sosMatrix); % They should be length 3
                    %
                    %             r=filter(Hd,ro);
                    
                    r=peakEQ(ro,eq_g(k_eq))';
                    r=ro;
                    if(plotting)
                        figure(1)
                        plot(r);
                    end
                    
                    [t_samp ref]=synch(r,ts_mod(1:end-n_sym*span),n_sym,plotting);
                    
                    r=r';
                    r=r(t_samp:end);
                    
                    if(plotting)
                        figure(2)
                        subplot(2,2,1)
                        pwelch(mod_signal)
                        title('Transmitted signal')
                        subplot(2,2,2)
                        pwelch(r)
                        title('Received signal')
                    end
                    
                 
                        Vnx=[];
                        Vny=[];
                        v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs); %vector containing data for 1 period.
                        % Demodulation of received signal
                        parfor(k=1:(length(data))/(2*levels)+ts_length+100)
                            Vnx=[Vnx r((k-1)*n_sym+1:k*n_sym).*cos(f1*v)];
                            Vny=[Vny r((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v)];
                        end
                                       
                    Hd=lpf(order(k_o),fc(k_fc),alfa(k_alfa));
                    Hx=2.*filter(Hd,Vnx);
                    Hy=2.*filter(Hd,Vny);
                    ML = length (Hx);
                    
                    if(plotting)
                        subplot(2,2,3)
                        pwelch(Vnx)
                        title('Received signal after x')
                        subplot(2,2,4)
                        pwelch(Hx)
                        title('Rx´d signal after LPF')
                        xlabel 'Normalized Frequency (\times\pi rad/sample)'
                        ylabel 'Magnitude (dB)'
                    end
                    
                    
                    
                    margin=100;
                    r_filt=[];
                    parfor(k=1:n_sym*(ts_length+2*margin))
                        r_aux= Hx(k) + Hy(k)*1i;
                        r_filt = [r_filt r_aux];
                    end
                    
                    n_samp = synch2(r_filt(1:(ts_length+2*margin)*n_sym),mconst_ts,n_sym);
                    if(n_samp < 0) break; end
                    mconst=[];
                    
                    for m=n_samp:n_sym:ML
                        Haux = Hx(m) + Hy(m)*1i;
                        mconst = [mconst Haux];
                    end
                    
                    if(plotting) scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Received Constellation'); end
                    
                    [phihat ref ref_re ref_im]=phase_estimation(mconst,mconst_ts);
                    %scatterplot(mconst*exp(-1i*phihat) / ref),grid
                    
                    % mconst_skewed = real (mconst(1:length(mconst_ts))*exp(-1i*phihat) /ref_re) + 1i* imag(mconst(1:length(mconst_ts))*exp(-1i*phihat) /ref_im);
                    %gama = skew_estimation(mconst_skewed ,mconst_ts);
                    batch_length=floor(t_block(k_t)/Ts);
                    mdem=[];
                    mconstdem=[];
                    ref2=1;
                    
                    mconst_skew=[];
                    variance=0;
                    for(k=1:floor(length(mconst)/batch_length))
                        mconst_phi = real(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2) + 1i*imag(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2);
                        mconstdem =[mconstdem mconst_phi];
                        
                        
                        for q=1:length(mconst_phi)
                            Hx(q)=real(mconst_phi(q));
                            Hy(q)=imag(mconst_phi(q));
                            
                            %                         Hys(q)=Hy(q) / cos(gama);
                            %                         Hxs(q)=Hx(q)+Hys(q)*sin(gama);
                            
                        end
                        %                     mconst_skew = [mconst_skew Hxs(1:length(mconst_phi))+1i*Hys(1:length(mconst_phi))];
                        
                        parfor m=1:length(mconst_phi)
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
                            aux=demod(fliplr(sym),levels,A);
                            aux=(Hx(m)-real(aux)).^2+(Hy(m)-imag(aux)).^2;
                            variance=variance+aux;
                        end
                        
                        if(mod(length(mdem),batch_length)==0)
                            demconst=demod(mdem((k-1)*batch_length*2*levels+1:k*batch_length*2*levels),levels,A);
                            [theta ref2]=offset_estimation(mconst_phi,demconst);
                            phihat=phihat+theta;
                            ref2=1;
                        end
                    end
                    
                    k=k+1;
                    mconst_phi = mconst((k-1)*batch_length+1:end) * exp(-1i*phihat) / (ref*ref2);
                    mconstdem =[mconstdem mconst_phi];
                    parfor q=1:length(mconst_phi)
                        Hx(q)=real(mconst_phi(q));
                        Hy(q)=imag(mconst_phi(q));
                    end
                    
                    parfor m=1:length(mconst_phi)
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
                        aux=demod(fliplr(sym),levels,A);
                        aux=(Hx(m)-real(aux)).^2+(Hy(m)-imag(aux)).^2;
                        variance=variance+aux;
                    end
                    
                    
                    %             scatterplot(mconstdem),grid
                    %             scatterplot(mconst_skew),grid
                    
                    test =[ts; data];
                    decoded=mdem;
                    variance
                   % scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
                    if(length(decoded)>=length(test))
                        decoded=decoded(1:length(test));
                        if(plotting) stem(test' ~= decoded); end
                        errors = sum(test(length(ts)+1:end)' ~= decoded(length(ts)+1:end));
                        
                        BER = errors / length(test(length(ts)+1:end)) * 100;
                        if(BER==0)
                            if(variance/length(test(length(ts)+1:end))<min_var)
                                % if(plotting == 0) close all; end
                                %scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
                                min_var=variance/length(test(length(ts)+1:end));
                                
                                best_fc=fc(k_fc);
                                best_gain=eq_g(k_eq);
                                best_o=order(k_o);
                                retrieve_coeffs(Hd);
                                best_t = t_block(k_t);
                                best_alfa = alfa(k_alfa);
                                best_variance = variance;
                                saveD_to_file('min_var.txt',[min_var best_fc best_gain best_o best_t best_alfa],6);
                            end
                            
                        end
                        
                    end
                    no_iterations=no_iterations-1
                end
            end
        end
    end
end
best_fc = best_fc
best_o = best_o
best_gain = best_gain
best_alfa = best_alfa
best_t = best_t
min_var = min_var
best_variance = best_variance
R = 2 * levels / Ts

toc
