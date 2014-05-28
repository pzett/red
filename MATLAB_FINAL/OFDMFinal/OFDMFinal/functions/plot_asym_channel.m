
function [] = plot_asym_channel(fs,FS,Nc,fc,phihat,ref,high)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
low = Nc-high;
delta_f=fs/FS;
f_v1=fc-delta_f*low:fs/FS:fc-1/delta_f;
f_v2=fc+1/delta_f:fs/FS:fc+delta_f*high;
ff = [f_v1 f_v2]/1000;
phases = [phihat(high+1:end); phihat(1:high)];
if(sum(diff(phases)>0.2))
        disp('There is a discontinuosity in the phase estimation. \n');
        disp('Sampling time might have slight offset. Consider retransmission.');
    end
references = [ref(high+1:end); ref(1:high)];
figure(2)
subplot(211);

stem(ff,phases); title('Phase estimation for each subcarrier'); xlabel('frequencies (kHz)'); ylabel('Phase (rad)');
line([fc/1000 fc/1000], [-pi pi],'Color','r','LineWidth',1);
axis([0 21 -pi pi]);
subplot(212)

stem(ff,references); title('Amplitude estimation for each subcarrier'); xlabel('frequencies (kHz)'); ylabel('Amplitude');
line([fc/1000 fc/1000], [0 max(references)],'Color','r','LineWidth',1)
axis([0 21 0 max(references)+200]);
end





