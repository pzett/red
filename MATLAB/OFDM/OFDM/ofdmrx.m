%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');

load('MQAM.mat')
load('ts_mod.mat')
fs=44100;

loops=1;
plotting=1;

% Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename) %grab log data
ro=extract_sound_from_log_data(log_data); %extract sound from log data.

figure(1)
r=peakEQ(ro,5.5)';
[t_samp]=synch(r,ts_mod);
subplot(312)
pwelch(r)
r=r';
r=r(t_samp:end);

t = 0: 1/fs : (length(r) - 1) /fs;
r=2*exp(-1i*2*pi*fc*t).*r;
subplot(313)
pwelch(r)

if(mod(length(r), S+P+FS) ~= 0 )
    r = [r  zeros(1,FS+S+P-mod(length(r), S+P+FS))];
end
n_cols = length(r)/(S+P+FS);
r_matrix = reshape ( r , S+P+FS,n_cols);
decoded = [];
for(k=1:n_cols)
    data_with_cp = r_matrix(:,k);
    data = [data_with_cp(P+1:end-S)];
    info = fft(data,FS);
    D = Nc;
    demod = [info(1:D/2); info(FS-((D/2)-1):FS)];
    decoded = [decoded; demod];
end

scatterplot(decoded)
  [phihat ref ref_re ref_im]=phase_estimation(decoded,mconst_ts(1:100))
    
 
  scatterplot(decoded*exp(-1i*phihat)/ref)
    scatterplot(decoded(1:ts_length)*exp(-1i*phihat)/ref)
    
    ts_matrix = reshape(decoded(1:ts_length),ts_length/Nc,Nc);
    scatterplot(decoded(1:20)*exp(-1i*phihat)/ref)
%errors = sum(transpose((decoded(1:ts_length + Nb / (2*levels))))~=mconst(ts_length+1:end-gb_length) )
