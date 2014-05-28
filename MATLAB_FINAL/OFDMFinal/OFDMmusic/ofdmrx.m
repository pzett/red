%Set up variables and workspace.
addpath('./functions/')
close all;
clear;
clc;
fclose('all');

load('OFDM.mat')
load('ts_mod.mat')
fs=44100; %sampling rate

loops=1; %apply loops ?
plotting=1; % plot output of functions ?
if(loops)
    g_eq = 5.6; %define equalizer gain, might not be needed, since this is OFDM.
else
    g_eq=5.6;
end
%Pull out info from sensor
% names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
% filename = char(names.filenames(end)); % Char converts cell to string
% copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
% log_data=get_log_data_from_FrameWork(filename) %grab log data
% ro=extract_sound_from_log_data(log_data); %extract sound from log data.

%system('adb devices');
ro = retrieve_data();

tic
for(k_eq=1:length(g_eq))
    
    
    %     r=peakEQ(ro,g_eq(k_eq))'; % apply equalizer
    Hd = hpf; % generate high pass filter to filter low pass component of noise
    
    r = filter(Hd,ro);
    figure(1)
    %r=ro; %received samples
    [t_samp t_end]=synch(r,ts_mod);
    subplot(412)
    pwelch(mod_signal,[],[],[],fs); title('PSD of transmitted signal');
    subplot(413)
    pwelch(r,[],[],[],fs); title('PSD of received signal after HPF')
    r=r';
    r=r(t_samp:t_end);
    if(plotting); colors = distinguishable_colors(Nc); end; %generate Nc distinguishable colors
    t = 0: 1/fs : (length(r) - 1) / fs;
    r=exp(-1i*2*pi*fc*t).*r; % multiply with the exponential
    subplot(414)
    pwelch(real(r),[],[],[],fs); title('PSD of received signal after (x) with complex exponential')
    
    if(mod(length(r), S+P+FS) ~= 0 )
        r = [r  zeros(1,FS+S+P-mod(length(r), S+P+FS))]; %fill with zeros for reshaping purposes
    end
    
    decoded = demodulate_OFDM(r,FS,S,P,Nc);
    % decoded = demodulate_OFDM_asym(r,FS,S,P,Nc,high);
    %     n_samp = synch2(decoded(1:ts_length+1000),mconst_ts)
    %     if(n_samp<=0); n_samp =1; end;
    %     decoded = decoded(n_samp:end);
    
    if(pilot == 1) %if pilots are being used, they must be removed and the gain and phases estimated.
        [pilots, decoded] = remove_pilots(decoded,pilot_int/(2*levels),ts_pilot_length,ts_length);
        size(pilots)
        ts_const = demodulate(ts_pilot,levels,A);
        [pilot_phase, pilot_ref] = estimate_pilot_phases(pilots,ts_const,Nc);
    end
    
    tsr_matrix = reshape(decoded(1:ts_length),Nc,ts_length/Nc); %received training sequence
    tss_matrix = reshape(mconst_ts,Nc,ts_length/Nc); % sent training sequence
    phihat = zeros(Nc,1); % vector containing the phase estimations for each subcarrier.
    ref = zeros(Nc,1); % vector containing the amplitude estimations for each subcarrier.
    for(k=1:Nc)
        [phihat(k), ref(k), qq, qa] = phase_estimation(tsr_matrix(k,:),tss_matrix(k,:)); % estimate the phase and gain
    end
    
    %generate vector of frequency for plotting and plot estimates for each frequency
    plot_channel(fs,FS,Nc,fc,phihat,ref);
    
    
    ref2 = 1; % variable to keep track of amplitude changes in time, might not be needed.
    
    batch_length = 16; % block length to update phase offset
    
    if(mod(Nc,batch_length) ~= 0) disp('You might want to reconsider your batch length.'); end
    %if(mod(pilot_int/(2*levels),batch_length) ~= 0 && pilot); disp('Pilot interval and batch length should match !'); pause; end
    
    %initialize variables for decoding
    mconst = transpose(decoded);
    mconstdem = [];
    mdem = [];
    if(pilot); trigger_pilots = 0;  pilot_index=1; end;
    
    
    for(k=1:floor(length(mconst)/batch_length))
        
        %     for(b=1:batch_length)
        %         mconst_phi(b) = mconst((k-1)*batch_length+b) * exp(-1i*phihat(b)) / (ref(b)*ref2);
        %     end
        
        mconst_phi=zeros(1,batch_length);
        
        for(b=0:batch_length-1)
            index = (k-1)*batch_length+b; % auxiliary variable so that the right phase and amplitude estimations are used.
            
            mconst_phi(b+1) = mconst(index+1) * exp(-1i*phihat(mod(index,Nc)+1)) / (ref(mod(index,Nc)+1)*ref2);
        end
        % plot(real(mconst_phi(b+1)),imag(mconst_phi(b+1)),'.');
        % mconst_phi = real(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2) + 1i*imag(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2);
        mconstdem =[mconstdem mconst_phi];
        
        for q=1:length(mconst_phi) % take real and imag. part of constellation to apply ML decision
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
        
        demconst=demodulate(mdem((k-1)*batch_length*2*levels+1:k*batch_length*2*levels),levels,A);
        [theta ref2]=offset_estimation(mconst_phi,demconst); %estimate the phase offset.
        ref2=1; % do not change amplitude, assume it is time invariant
        
        for(b=0:batch_length-1)
            index = (k-1)*batch_length+b;
            
            phihat(mod(index,Nc)+1) = phihat(mod(index,Nc)+1) + theta;
            %phihat=phihat+theta;
        end
        
        if(pilot) %if pilots are being used
            if(length(mconstdem) == ts_length); trigger_pilots = 1; end
            
            if(mod(length(mconstdem) - ts_length, pilot_int / (2*levels) )==0 && trigger_pilots && ((length(mconstdem)-ts_length) ~= 0) )
                if(pilot_index < size(pilot_phase,2))
                    (length(mconstdem)-ts_length)
                    phihat = pilot_phase(:,pilot_index); %new phase estimation
                    ref = pilot_ref(:,pilot_index);      %new amplitude estimation
                    pilot_index=pilot_index+1
                end
            end
        end
    end
    hold off
    
    k=k+1; %process last batch.
    mconst_phi=zeros(1,length( mconst((k-1)*batch_length+1:end)));
    for(b=0:length(mconst_phi)-1)
        index = (k-1)*batch_length+b;
        mconst_phi(b+1) = mconst(index+1) * exp(-1i*phihat(mod(index,Nc)+1)) / (ref(mod(index,Nc)+1)*ref2);
    end
    
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
    
    if(file)
        file_data = mdem(ts_length*2*levels+1:ts_length*2*levels+length(data_sent));
        bitstobytes(file_data,'output.wav');
    else
        test =[ts; data_sent]; %vector to compare with the decoded and compute BER.
        figure(4)
        if(plotting)
            subplot(122)
            plot(real(mconstdem(ts_length+1:length(test)/(2*levels))),imag(mconstdem(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
            subplot(121)
            plot(real(decoded(ts_length+1:length(test)/(2*levels))),imag(decoded(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation');
        end
        
        
        
        
        %plot(real(mconstdem(ts_length+1:length(test)/(2*levels))),imag(mconstdem(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
        
        decoded=mdem;
        
        if(length(decoded)>=length(test))
            decoded=decoded(1:length(test));
            if(plotting)
                figure(6)
                subplot(211)
                stem(test' ~= decoded); title('Errors in the transmission'); xlabel('Samples'); ylabel('Error');
                subplot(212)
                carrier_errors(test(length(ts)+1:end)', decoded(length(ts)+1:end),Nc);
            end
            errors = sum(test(length(ts)+1:end)' ~= decoded(length(ts)+1:end));
            BER = errors / length(test(length(ts)+1:end)) * 100
        end
    end
end


mod_signal_length = length(mod_signal)/fs;

%R = fs*Nc*2*levels / (FS+S+P)

% R = ((ts_length+2*gb_length)*2*levels + Nb) / mod_signal_length
EffectiveRate = Nb / mod_signal_length

fprintf('Transmitted: %g bytes in %g seconds\n',Nb/8,mod_signal_length);

T = toc;
fprintf('Elapsed time: %g seconds. \n',T);
% figure(5)
%     hold on; grid on;
%     for(k=ts_length:length(test)/(2*levels))
%
%         plot(real(mconstdem(k+1)),imag(mconstdem(k+1)),'Marker','.','MarkerEdgeColor',colors(mod(k-ts_length,Nc)+1,:),'LineStyle','none');
%     end
% title('Received constellation in each subcarrier'); xlabel('I'); ylabel('Q');


%     consttx = reshape(demconst,batch_length/Nc,Nc);
%     constrx = reshape(mconst_phi,batch_length/Nc,Nc);
%     for(b=1:Nc)
%         [theta(b) ref2(b)] = offset_estimation(constrx(:,b),consttx(:,b));
%     end
%     phihat = phihat + transpose(theta);
%errors = sum(transpose((decoded(1:ts_length + Nb / (2*levels))))~=mconst(ts_length+1:end-gb_length) )
