function [ ts_mod ] = save_and_plot( FS,S,P,up_signal,mod_signal,fs,Nc,gb_length,ts_length,Nb,gb_end_l,levels)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
%Save, send to phone and plot important plots.


ts_mod = up_signal(gb_length/Nc*(FS+S+P)+1:gb_length/Nc*(FS+S+P)+(FS+S+P)*ts_length/Nc); %save ts to synchronize in the receiver
ts_mod=ts_mod/(max(abs(ts_mod)+0.001));

if(mod(gb_length,Nc) || mod(ts_length,Nc)); disp('gb or ts length should be divisable by Nc!!!'); end
%wavwrite(mod_signal, fs, 'mod_signal.wav'); % write to wav file
create_file_of_shorts('test_signal.dat',mod_signal*(2^15-1));
copy_file_to_all('test_signal.dat');
%copy_file_from_working_directory_to_sdcard( 'test_signal.dat' ); % 1phone


mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length);
fprintf('Estimated effective rate is %g bps \n', Nb/mod_signal_length);
rate_eq= Nb/((P+S+FS)/Nc*(gb_length+ts_length+gb_end_l+Nb/(2*levels))/fs);
fprintf('Rate according to equation is %g bps \n',rate_eq);



figure(1)
% subplot(211)
% segment = up_signal(200:400); tt = 0 : 1/fs : (length(segment)-1)/fs;
% plot(tt,segment); title('Segment of transmitted signal (OFDM) in time'); xlabel('time'); ylabel('Amplitude');
% subplot(212)
pwelch(up_signal,[],[],[],fs); title('PSD of transmitted signal (OFDM)')



figure;hold on;grid on;
N = 1000:2000:1e7;
rate_eq = zeros(length(N),1);
levels_p = 3:4;
color = distinguishable_colors(length(levels_p));
for(q=1:length(levels_p))
    for(k=1:length(N))
        rate_eq(k)= N(k)/((P+S+FS)/Nc*(gb_length+ts_length+gb_end_l+N(k)/(2*levels_p(q)))/fs);
    end
    plot(N/8000,rate_eq/1000,'Color',color(q,:),'LineWidth',1.5);
    
    
end
title('Rate vs Size vs Constellation')
xlabel('Size of transmission (kB)'); ylabel('Achieved Rate (kbps)');
leg = [[num2str(2.^(2*levels_p(1))),('-QAM ')] ; [num2str(2.^(2*levels_p(2))),('-QAM')]];
legend(leg,'Location','Best');

line([0 max(N) / 8000],[128 128],'LineWidth',3.2,'Color',[0 100 0]/256,'LineStyle','--',...
    'Tag','128 kbps');

rate_point = (Nb)/((P+S+FS)/Nc*(gb_length+ts_length+gb_end_l+(Nb)/(2*levels))/fs);
plot(Nb/8000,rate_point/1000,'ro')
str = sprintf('(%.1f kB,%.1f kbps)',Nb/8000,rate_point/1000);
text(Nb/8000,rate_point/1000,str,'VerticalAlignment','top', ...
    'HorizontalAlignment','left','BackgroundColor',[.7 .9 .7],'FontSize',20);

rate_point = (Nb)/((P+S+FS)/Nc*(gb_length+ts_length+gb_end_l+(Nb)/(2*(levels+1)))/fs);
plot(Nb/8000,rate_point/1000,'ro')
str = sprintf('(%.1f kB,%.1f kbps)',Nb/8000,rate_point/1000);
text(Nb/8000,rate_point/1000,str,'VerticalAlignment','top', ...
    'HorizontalAlignment','left','BackgroundColor',[255 127 80]/256,'FontSize',20);





end

