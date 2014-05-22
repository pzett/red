function [ phihat,ref ] = estimate_channel(decoded,Nc,ts_length,asym,FS,fc,mconst_ts,fs,high);
%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Estimate the channel in terms of amplitude for each used frequency.
% The estimations are saved in 2 vectors.
tsr_matrix = reshape(decoded(1:ts_length),Nc,ts_length/Nc); %received training sequence
tss_matrix = reshape(mconst_ts,Nc,ts_length/Nc); % sent training sequence
phihat = zeros(Nc,1); % vector containing the phase estimations for each subcarrier.
ref = zeros(Nc,1); % vector containing the amplitude estimations for each subcarrier.
for(k=1:Nc)
    [phihat(k), ref(k), qq, qa] = phase_estimation(tsr_matrix(k,:),tss_matrix(k,:)); % estimate the phase and gain
end


%generate vector of frequency for plotting and plot estimates for each frequency
if(asym)
    plot_asym_channel(fs,FS,Nc,fc,phihat,ref,high);
else
    plot_channel(fs,FS,Nc,fc,phihat,ref);
end

end

