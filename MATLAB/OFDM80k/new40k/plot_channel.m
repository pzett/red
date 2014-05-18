function [ ] = plot_channel(fs,FS,Nc,fc,phihat,ref)

delta_f=fs/FS;
f_v1=fc-delta_f*Nc/2:fs/FS:fc-1/delta_f;
f_v2=fc+1/delta_f:fs/FS:fc+delta_f*Nc/2;
ff = [f_v1 f_v2]/1000;
phases = [phihat(Nc/2+1:end); phihat(1:Nc/2)];
references = [ref(Nc/2+1:end); ref(1:Nc/2)];
figure(2)
subplot(211); 
stem(ff,phases); title('Phase estimation for each subcarrier'); xlabel('frequencies (kHz)'); ylabel('Phase (rad)');
subplot(212)
stem(ff,references); title('Amplitude estimation for each subcarrier'); xlabel('frequencies (kHz)'); ylabel('Amplitude');
end

