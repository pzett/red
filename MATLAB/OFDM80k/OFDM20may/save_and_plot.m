function [ ts_mod ] = save_and_plot( FS,S,P,up_signal,mod_signal,fs,Nc,gb_length,ts_length,Nb,gb_end_l,levels)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
ts_mod = up_signal(gb_length/Nc*(FS+S+P)+1:gb_length/Nc*(FS+S+P)+(FS+S+P)*ts_length/Nc); %save ts to synchronize in the receiver
ts_mod=ts_mod/(max(abs(ts_mod)+0.001));

if(mod(gb_length,Nc) || mod(ts_length,Nc)); disp('gb or ts length should be divisable by Nc!!!'); end
%wavwrite(mod_signal, fs, 'mod_signal.wav');
create_file_of_shorts('test_signal.dat',mod_signal*(2^15-1));
copy_file_to_all('test_signal.dat');
%copy_file_from_working_directory_to_sdcard( 'test_signal.dat' );

mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
fprintf('Modulated signal: %g seconds long \n',mod_signal_length);
fprintf('Estimated effective rate is %g bps \n', Nb/mod_signal_length);
rate_eq= Nb/((P+S+FS)/Nc*(gb_length+ts_length+gb_end_l+Nb/(2*levels))/fs);
fprintf('Rate according to equation is %g bps \n',rate_eq);
figure(1)
subplot(211)
segment = up_signal(200:400); tt = 0 : 1/fs : (length(segment)-1)/fs;
plot(tt,segment); title('Segment of transmitted signal (OFDM) in time'); xlabel('time'); ylabel('Amplitude');
subplot(212)
pwelch(up_signal,[],[],[],fs); title('PSD of transmitted signal (OFDM)')



figure;hold on;grid on;
N = 1000:2000:8e6;
rate_eq = zeros(length(N),1);
levels = 3:5;
color = distinguishable_colors(length(levels));
for(q=1:length(levels))
    for(k=1:length(N))
        rate_eq(k)= N(k)/((P+S+FS)/Nc*(gb_length+ts_length+gb_end_l+N(k)/(2*levels(q)))/fs);
    end
    plot(N/1000,rate_eq/1000,'Color',color(q,:));
end
title('Rate vs Size vs Constellation')
xlabel('Size of transmission (kb)'); ylabel('Achieved Rate (kbps)'); 
legend(num2str(2.^(2*levels')))
line([0 max(N) / 1000],[128 128],'LineWidth',3.5,'Color',[0 100 0]/256,'LineStyle','--',...
                'Tag','128 kbps');
end

