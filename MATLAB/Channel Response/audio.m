
%--------------
%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);
log_data=get_log_data_from_FrameWork(filename); 
r=extract_sound_from_log_data(log_data); %received sequence

figure; %plot transmited sound  
%pwelch(y)
% Set axes appropriately
[Ryy,f]=plotspectrum(r);
maxPSD=max(Ryy);
Ryy=Ryy-maxPSD;
plot(f*fs/1000,Ryy,'k','LineStyle','-','LineWidth', 1.5);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
title('PSD output');
axis([0 22.1 min(Ryy-3) max(Ryy+3)]);
grid on;
