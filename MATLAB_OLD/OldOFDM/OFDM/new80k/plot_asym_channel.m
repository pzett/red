function [] = plot_asym_channel(fs,FS,Nc,fc,phihat,ref,high)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
low = Nc-high;
delta_f=fs/FS;
f_v1=fc-delta_f*low:fs/FS:fc-1/delta_f;
f_v2=fc+1/delta_f:fs/FS:fc+delta_f*high;
ff = [f_v1 f_v2]/1000;
phases = [phihat(high+1:end); phihat(1:high)];
references = [ref(high+1:end); ref(1:high)];
figure(2)
subplot(211);
stem(ff,phases); title('Phase estimation for each subcarrier'); xlabel('frequencies (kHz)'); ylabel('Phase (rad)');
subplot(212)
stem(ff,references); title('Amplitude estimation for each subcarrier'); xlabel('frequencies (kHz)'); ylabel('Amplitude');
end





