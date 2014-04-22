%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');

load('MQAM.mat')
load('ts_mod.mat')
fs=44100;
Ts=n_sym/fs;
loops=0;


if(loops)
    fc = 3600:50:4100;
    order=6:10;
    eq_g=7:0.2:8.2;
else
    fc=3700;
    order=8;
    eq_g=7;
end

%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename) %grab log data
ro=extract_sound_from_log_data(log_data); %extract sound from log data.

for(k_fc=1:length(fc))
    for(k_o=1:length(order))
        for(k_eq=1:length(eq_g))
            
            d  = fdesign.parameq('F0,BW,BWp,Gref,G0,GBW,Gp',0.2732,0.15,0.03,0,eq_g(k_eq),3,5);
            Hd = design(d);
            r=filter(Hd,ro);
            
            figure(1)
            plot(r)
            
            [t_samp ref]=synch(r,ts_mod,n_sym);
            r=r';
            r=r(t_samp:end);
            
            figure(2)
            subplot(2,2,1)
            pwelch(mod_signal)
            title('Transmitted signal')
            subplot(2,2,2)
            pwelch(r)
            title('Received signal')
            
            if(continuous)
                t=0:1/fs:length(r)/fs-1/fs;
                Vnx=r.*cos(2*pi*f1*t);
                Vny=-r.*sin(2*pi*f1*t);
                Vnx=Vnx(1:n_sym*(length(data)/(2*levels)+ts_length+20));
                Vny=Vny(1:n_sym*(length(data)/(2*levels)+ts_length+20));
            else
                Vnx=[];
                Vny=[];
                v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs); %vector containing data for 1 period.
                % Demodulation of received signal
                for(k=1:(length(data))/(2*levels)+ts_length)
                    Vnx=[Vnx r((k-1)*n_sym+1:k*n_sym).*cos(f1*v)];
                    Vny=[Vny r((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v)];
                end
            end
            
            Hd=lpf(order(k_o),fc(k_fc));
            Hx=2.*filter(Hd,Vnx);
            Hy=2.*filter(Hd,Vny);
            ML = length (Hx);
            
            
            subplot(2,2,3)
            pwelch(Vnx)
            title('Received signal after x')
            subplot(2,2,4)
            pwelch(Hx)
            
            title('Rx´d signal after LPF')
            xlabel 'Normalized Frequency (\times\pi rad/sample)'
            ylabel 'Magnitude (dB)'
            
            margin=200;
            r_filt=[];
            for(k=1:n_sym*(ts_length+2*margin))
                r_aux= Hx(k) + Hy(k)*1i;
                r_filt = [r_filt r_aux];
            end
            
            n_samp = synch2(r_filt(1:(ts_length+2*margin)*n_sym),mconst_ts,n_sym)
            
            mconst=[];
            
            for m=n_samp:n_sym:ML
                Haux = Hx(m) + Hy(m)*1i;
                mconst = [mconst Haux];
            end
            
            scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Received Constellation');
            
            [phihat ref]=phase_estimation(mconst,mconst_ts)
            batch_length=floor(0.05/Ts);
            mdem=[];
            mconstdem=[];
            ref2=1;
            
            for(k=1:floor(length(mconst)/batch_length))
                mconst_phi = mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat) / (ref*ref2);
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
                
                if(mod(length(mdem),batch_length)==0)
                    demconst=demod(mdem((k-1)*batch_length*2*levels+1:k*batch_length*2*levels),levels,A);
                    [theta ref2]=offset_estimation(mconst_phi,demconst)
                    phihat=phihat+theta;
                    ref2=1;
                end
            end
            
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
            
            test =[ts; data];
            decoded=mdem;
            if(length(decoded)>=length(test))
                decoded=decoded(1:length(test));
                errors = sum(test' ~= decoded)
                stem(test' ~= decoded);
                BER = errors / length(test) * 100
                %R = 2 * levels / Ts
                if(BER==0)
                    scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
                    fc(k_fc)
                    eq_g(k_eq)
                    order(k_o)
                    pause
                end
                
            end
           close all 
        end
    end
end


