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

%Pull out info from sensor
names=list_sensor_log_files_on_sdcard;%grabs list of .csv files on phone
filename = char(names.filenames(end)); % Char converts cell to string
copy_file_from_sdcard_to_working_directory(filename);%copy file to folder
log_data=get_log_data_from_FrameWork(filename) %grab log data
ro=extract_sound_from_log_data(log_data); %extract sound from log data.

figure(1)
r=peakEQ(ro,7)';
%r=ro;
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
cp1 = zeros(P,n_cols);
cp2 = zeros(P,n_cols);
for(k=1:n_cols)
    data_with_cp = r_matrix(:,k);
    cp1(:,k) = data_with_cp(1:P);
    cp2(:,k) = data_with_cp(end-S-P+1:end-S);
    data = [data_with_cp(P+1:end-S)];
    info = fft(data,FS);
    D = Nc;
    demod = [info(1:D/2); info(FS-((D/2)-1):FS)];
    decoded = [decoded; demod];
end

if(pilot == 1)
    [pilots decoded] = remove_pilots(decoded,pilot_int,ts_pilot_length,ts_length)
end


tsr_matrix = reshape(decoded(1:ts_length),Nc,ts_length/Nc);
tss_matrix = reshape(mconst_ts,Nc,ts_length/Nc);
phihat = zeros(Nc,1);
ref = zeros(Nc,1);
for(k=1:Nc)
    [phihat(k) ref(k) qq qa] = phase_estimation(tsr_matrix(k,:),tss_matrix(k,:));
end

ref2 = 1;
batch_length = 20;
mconst = transpose(decoded);
mconstdem = [];
mdem = [];

for(k=1:floor(length(mconst)/batch_length))
   
    %     for(b=1:batch_length)
    %         mconst_phi(b) = mconst((k-1)*batch_length+b) * exp(-1i*phihat(b)) / (ref(b)*ref2);
    %     end
    
     mconst_phi=zeros(1,batch_length);
    for(b=0:batch_length-1)
        index = (k-1)*batch_length+b;
        mconst_phi(b+1) = mconst(index+1) * exp(-1i*phihat(mod(index,Nc)+1)) / (ref(mod(index,Nc)+1)*ref2);
    end
    %     scatterplot(mconst_phi)
    %     pause
    %mconst_phi = real(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2) + 1i*imag(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2);
    mconstdem =[mconstdem mconst_phi];
    
    for q=1:length(mconst_phi)
        Hx(q)=real(mconst_phi(q));
        Hy(q)=imag(mconst_phi(q));
    end
    
    for m=1:length(mconst_phi)
        sym=[];
        th_x=0;th_y=0;
        i_x=0;i_y=0;
        for n=1:levels
            if Hy(m) > th_y
                sym = [sym 0];
                i_y=1;
            else
                sym = [sym 1];
                i_y=-1;
            end
            
            if Hx(m) > th_x
                sym = [sym 0];
                i_x=1;
            else
                sym = [sym 1];
                i_x=-1;
            end
            th_y = th_y + A*i_y*(2^(levels-n));
            th_x =  th_x + A*i_x*(2^(levels-n));
        end
        mdem=[mdem fliplr(sym)];
        
        
    end
    demconst=demodulate(mdem((k-1)*batch_length*2*levels+1:k*batch_length*2*levels),levels,A);
    [theta ref2]=offset_estimation(mconst_phi,demconst);
    %phihat=phihat+theta;
    for(b=0:batch_length-1)
        index = (k-1)*batch_length+b;
        
        phihat(mod(index,Nc)+1) = phihat(mod(index,Nc)+1) + theta;
    end
    ref2=1;
end

k=k+1;
mconst_phi=zeros(1,length( mconst((k-1)*batch_length+1:end)));
for(b=0:length(mconst_phi)-1)
    index = (k-1)*batch_length+b;
    mconst_phi(b+1) = mconst(index+1) * exp(-1i*phihat(mod(index,Nc)+1)) / (ref(mod(index,Nc)+1)*ref2);
end

mconstdem =[mconstdem mconst_phi];

for q=1:length(mconst_phi)
    Hx(q)=real(mconst_phi(q));
    Hy(q)=imag(mconst_phi(q));
end

for m=1:length(mconst_phi)
    sym=[];
    th_x=0;th_y=0;
    i_x=0;i_y=0;
    for n=1:levels
        if Hy(m) > th_y
            sym = [sym 0];
            i_y=1;
        else
            sym = [sym 1];
            i_y=-1;
        end
        
        if Hx(m) > th_x
            sym = [sym 0];
            i_x=1;
        else
            sym = [sym 1];
            i_x=-1;
        end
        th_y = th_y + A*i_y*(2^(levels-n));
        th_x =  th_x + A*i_x*(2^(levels-n));
    end
    
    mdem=[mdem fliplr(sym)];
    
end

test =[ts; data_sent];

scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');


decoded=mdem;

if(length(decoded)>=length(test))
    decoded=decoded(1:length(test));
    if(plotting)
        figure(3)
        stem(test' ~= decoded);
    end
    errors = sum(test(length(ts)+1:end)' ~= decoded(length(ts)+1:end));
    BER = errors / length(test(length(ts)+1:end)) * 100
end

mod_signal_length = length(mod_signal)/fs;
%R = fs*Nc*2*levels / (FS+S+P)
R = ((ts_length+2*gb_length)*2*levels + Nb) / mod_signal_length
effective_rate = Nb / mod_signal_length






%     consttx = reshape(demconst,batch_length/Nc,Nc);
%     constrx = reshape(mconst_phi,batch_length/Nc,Nc);
%     for(b=1:Nc)
%         [theta(b) ref2(b)] = offset_estimation(constrx(:,b),consttx(:,b));
%     end
%     phihat = phihat + transpose(theta);
%errors = sum(transpose((decoded(1:ts_length + Nb / (2*levels))))~=mconst(ts_length+1:end-gb_length) )
