%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');

load('MQAM.mat')
load('ts_mod.mat')
fs=44100; %sampling rate
use_eq = 0;
use_hpf = 0;
loops=1; %apply loops ?
plotting=1; % plot output of functions ?
if(loops)
    g_eq = 7.0; %define equalizer gain, might not be needed, since this is OFDM.
else
    g_eq=5.6;
end

%Pull out info from sensor
% names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
% filename = char(names.filenames(end)); % Char converts cell to string
% copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
% log_data=get_log_data_from_FrameWork(filename) %grab log data
% ro=extract_sound_from_log_data(log_data); %extract sound from log data.


%system('adb devices')
ro = retrieve_data();

tic
for(k_eq=1:length(g_eq))
    if(use_eq)
        r=peakEQ(ro,g_eq)'; % apply equalizer
        
        if(use_hpf)
            Hd = hpf; % generate high pass filter to filter low pass component of noise
            r = filter(Hd,r);
        end
    else
        r=ro;
    end
    
    [t_samp_o, t_end]=synch(r,ts_mod,fs,mod_signal);
    
    r=r';
    margin = 5;
    t_samp = find_sampling_time(asym,ts_length,margin,r,fs,fc,FS,S,P,Nc,high,mconst_ts,t_end,t_samp_o);
    
    r=r(t_samp:t_end);
    
    
    if(plotting); colors = distinguishable_colors(Nc); end; %generate Nc distinguishable colors
    
    t = 0: 1/fs : (length(r) - 1) / fs;
    r=exp(-1i*2*pi*fc*t).*r; % multiply with the exponential
    subplot(414)
    pwelch(real(r),[],[],[],fs); title('PSD of received signal after (x) with complex exponential')
    
    
    decoded = dem_OFDM(r,FS,S,P,Nc,high,fs,asym);
    %         n_samp = synch2(decoded(1:ts_length+1000),mconst_ts)
    %         if(n_samp<=0); n_samp =1; end;
    %         decoded = decoded(n_samp:end);
    
    if(pilot == 1) %if pilots are being used, they must be removed and the gain and phases estimated.
        [pilots, decoded] = remove_pilots(decoded,pilot_int/(2*levels),ts_pilot_length,ts_length);
        size(pilots)
        ts_const = demodulate(ts_pilot,levels,A);
        [pilot_phase, pilot_ref] = estimate_pilot_phases(pilots,ts_const,Nc);
    end
    
    
    [phihat,ref] = estimate_channel(decoded,Nc,ts_length,asym,FS,fc,mconst_ts,fs,high);
    
    
    
    batch_length = 10; % block length to update phase offset
    
    [ mdem,mconstdem ] = decoder(levels,asym, batch_length,high,phihat,ref,decoded,pilot,ts_length,Nc,A );
    

    
    if(file)
        if(code)
            file_data = LDPCdec(mdem(ts_length*2*levels+1:end),rate);
        else
 
            file_data = mdem(ts_length*2*levels+1:end);
            
        end
        test=[ts;data_sent];
        if(intlv);  file_data = scramble(file_data'); demodulated = file_data'; end;
        figure(8)
        errors = sum(test(length(ts)+1:end) ~= demodulated(1:length(data_sent))');
        BER = errors / length(test(length(ts)+1:end)) * 100
        plot(real(mconstdem(1:ts_length)),imag(mconstdem(1:ts_length)),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
        figure(6)
        plot(real(mconstdem(ts_length+1:length(test)/(2*levels))),imag(mconstdem(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
        bitstobytesnew(demodulated);
        demodulated = demodulated';
    
    else
        if(code)
            test=[ts;data_sent];
            test_encoded=[ts;data_encoded];
            dem_enc = mdem(length(ts)+1:length(test_encoded));
            errors = sum(test_encoded(length(ts)+1:end) ~= dem_enc(1:end)');
            BER_BEFORE_DEC = errors / length(test_encoded(length(ts)+1:end)) * 100
            demodulated = LDPCdec(dem_enc,rate);
            demodulated = demodulated(1:length(test)-length(ts));
            errors = sum(test(length(ts)+1:end) ~= demodulated(1:end));
            BER_AFTER_DEC = errors / length(test(length(ts)+1:end)) * 100
        else
            
            test =[ts; data_sent]; %vector to compare with the decoded and compute BER
            demodulated=mdem;
            if(length(demodulated)>=length(test))
                demodulated=demodulated(length(ts)+1:length(test))';
                if(intlv)
                   demodulated = scramble(demodulated);
                end
                %demodulated=deinterleaving(deinterleaving(demodulated,9,11),9,11);
                errors = sum(test(length(ts)+1:end) ~= demodulated(1:end));
                BER = errors / length(test(length(ts)+1:end)) * 100
            end
        end
    end
end

mod_signal_length = length(mod_signal)/fs;


R = ((ts_length+2*gb_length)*2*levels + Nb) / mod_signal_length
effective_rate = Nb / mod_signal_length

fprintf('Transmitted: %g bytes in %g seconds\n',Nb/8,mod_signal_length);

T = toc;
fprintf('Elapsed time: %g seconds. \n',T);

figure(4)
if(plotting)
    subplot(122)
    plot(real(mconstdem(ts_length+1:length(test)/(2*levels))),imag(mconstdem(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
    subplot(121)
    plot(real(decoded(ts_length+1:length(test)/(2*levels))),imag(decoded(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation');
end

% figure(5)
% hold on; grid on;
% subplot(122); hold on; grid on;
% for(k=ts_length:length(test)/(2*levels))
%     plot(real(mconstdem(k+1)),imag(mconstdem(k+1)),'Marker','.','MarkerEdgeColor',colors(mod(k-ts_length,Nc)+1,:),'LineStyle','none');
% end
% title('Received constellation in each subcarrier after correction'); xlabel('I'); ylabel('Q');
% subplot(121); hold on; grid on;
% for(k=ts_length:length(test)/(2*levels))
%
%     plot(real(decoded(k+1)),imag(decoded(k+1)),'Marker','.','MarkerEdgeColor',colors(mod(k-ts_length,Nc)+1,:),'LineStyle','none');
%
% end
% title('Received constellation in each subcarrier'); xlabel('I'); ylabel('Q');

figure(6)
plot(real(mconstdem(ts_length+1:length(test)/(2*levels))),imag(mconstdem(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');

if(plotting)
    figure(7)
    subplot(211)
    stem(test(length(ts)+1:end) ~= demodulated(1:length(data_sent))); title('Errors in the transmission'); xlabel('Samples'); ylabel('Error');
    subplot(212)
    carrier_errors(test(length(ts)+1:end), demodulated(1:length(data_sent)),Nc);
end
%     consttx = reshape(demconst,batch_length/Nc,Nc);
%     constrx = reshape(mconst_phi,batch_length/Nc,Nc);
%     for(b=1:Nc)
%         [theta(b) ref2(b)] = offset_estimation(constrx(:,b),consttx(:,b));
%     end
%     phihat = phihat + transpose(theta);
%errors = sum(transpose((decoded(1:ts_length + Nb / (2*levels))))~=mconst(ts_length+1:end-gb_length) )
