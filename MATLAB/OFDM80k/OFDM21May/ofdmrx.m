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

%system('adb devices')
ro = retrieve_data('4df789074129bfb5');

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
    figure
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
      
    if(pilot == 1) %if pilots are being used, they must be removed and the gain and phases estimated.
        [pilots, decoded] = remove_pilots(decoded,pilot_int/(2*levels),ts_pilot_length,ts_length);
        ts_const = demodulate(ts_pilot,levels,A);
        [pilot_phase, pilot_ref] = estimate_pilot_phases(pilots,ts_const,Nc);
    end

    [phihat,ref] = estimate_channel(decoded,Nc,ts_length,asym,FS,fc,mconst_ts,fs,high);
 
    batch_length = 10; % block length to update phase offset
    
    [ mdem,mconstdem,phi_mat] = decoder(levels,asym, batch_length,high,phihat,ref,decoded,pilot,ts_length,Nc,A );
    
    process_bits
   
end

mod_signal_length = length(mod_signal)/fs;

plot_surf 

R = ((ts_length+2*gb_length)*2*levels + Nb) / mod_signal_length
effective_rate = Nb / mod_signal_length

fprintf('Transmitted: %g bytes in %g seconds\n',Nb/8,mod_signal_length);

T = toc;
fprintf('Elapsed time: %g seconds. \n',T);

plot_graphs_rx
%     consttx = reshape(demconst,batch_length/Nc,Nc);
%     constrx = reshape(mconst_phi,batch_length/Nc,Nc);
%     for(b=1:Nc)
%         [theta(b) ref2(b)] = offset_estimation(constrx(:,b),consttx(:,b));
%     end
%     phihat = phihat + transpose(theta);
%errors = sum(transpose((decoded(1:ts_length + Nb / (2*levels))))~=mconst(ts_length+1:end-gb_length) )
