%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Script to plot the changes of the phase in time and frequency of the
% channel
figure
t = 1 : size(phi_mat,1);
low = Nc-high;
delta_f=fs/FS;
f_v1=fc-delta_f*low:fs/FS:fc-1/delta_f;
f_v2=fc+1/delta_f:fs/FS:fc+delta_f*high;
ff = [f_v1 f_v2]/1000;
phi_mat = [phi_mat(:,high+1:end) phi_mat(:,1:high)]';

surf(t,ff,phi_mat); shading interp;
xlabel('time (in OFDM symbols)')
ylabel('frequency (kHz)')
zlabel('Phase rotation (rad)')

% figure;hold on; grid on;
% for(k=1:30:Nc-1)
%     plot(t(1:end-1),phi_mat(k,1:end-1),'Color',colors(k,:))
% end
% 
hold off;