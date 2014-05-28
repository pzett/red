%MQAM

%Set up variables and workspace.
close all;
clear;
clc;
fs=44100; %Sampling frequency

%Initialize variables
nr_blocks = 1; 
EbN0=0:22;
%EbN0=21;

cr={'0','1/2','2/3','3/4','4/5'};
cr={'3/4'};
bw=fs/2;
loops=0;
plotting=0;


%Set up determining variables


levels = 4;
Nb=50001; %Number of bits to transmit


f1=fs/4;
%f1=10000;
n_sym=8;
Ts=n_sym/fs;
R = 2 * levels / Ts;
ts_length=104; %in number of symbols
gb_length=100; %in number of symbols
alfa = 2;
A=1; %amplitude to control distance between points in const -> does not work

SNR=EbN0+10*log10(R/bw);

continuous=0;
win=gausswin(n_sym,alfa)';
%win=ones(n_sym,1)';
s = rng;
ts=randi([0,1],ts_length*2*levels,1);
%ts = randint(ts_length*2*levels,1,2);
gb = randi([0,1],gb_length*2*levels,1);%zeros(gb_length*2*levels,1);
data = randi([0,1],Nb,1);
 rng(s);
for coderate=1:length(cr);
nr_errors = zeros(1, length(EbN0)); 
    for SNR_index=1:length(SNR)
    for blk = 1:nr_blocks

        %% coding
[encdata, Nb_enc]=convencode(data,char(cr(coderate)));
left = rem(Nb+(ts_length+gb_length)*2*levels,2*levels);
bit_stream = [gb' ts' encdata' (zeros(2*levels-left,1))' gb'];
L=length(bit_stream);


%Generate auxiliar variables to compute tx_signal with window and RRC
symbol=ones(1,n_sym);
symbol2=ones(1,1);
mx=[]; my=[];
mx2=[]; my2=[];

x=0;
y=0;
x2=0;
y2=0;
for n=0:2*levels:L-2*levels
    bit=[];
    xi=0;
    yi=0;
    
    for m= 1:2:2*levels
        if bit_stream(n+m)==0      
            xi=xi+A*(2^((m-1)/2));
            
        else
            xi=xi-A*(2^((m-1)/2));
            
        end
        if bit_stream(n+m+1)==0
            yi=yi+A*(2^((m-1)/2));
            
        else
            yi=yi-A*(2^((m-1)/2));
            
        end
    end
    
    x=xi*symbol;
    y=yi*symbol;
    x2=xi*symbol2;
    y2=yi*symbol2;
        
    mx=[mx x];
    my=[my y];
    mx2=[mx2 x2];
    my2=[my2 y2];
end


mconst = mx + my*1i; %Constellation of sent dats
if(continuous==0)
v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs); %vector containing data for 1 period.
qam=[];
for(k=1:length(bit_stream)/(2*levels))
    qam=[qam win.*(real(mconst((k-1)*n_sym+1:k*n_sym)).*cos(f1*v)-imag(mconst((k-1)*n_sym+1:k*n_sym)).*sin(f1*v))];
   
end

else
t=0:1/fs:length(mconst)/fs-1/fs; 
qam=real(mconst).*cos(2*pi*f1*t)-imag(mconst).*sin(2*f1*pi*t);
for(k=1:length(bit_stream)/(2*levels))
    qam((k-1)*n_sym+1:k*n_sym)=win.*qam((k-1)*n_sym+1:k*n_sym);
end
end

mconst_ts=mconst(gb_length*n_sym+1:n_sym:n_sym*(gb_length+ts_length));

%rectangular/hanning window
ts_mod=qam((gb_length*n_sym+1:(gb_length+ts_length)*n_sym));%retrieve modulated training sequence

%figure(3)
%subplot(1,2,1)
%pwelch(qam)

%scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Constellation before sending');

 %rectangular/hanning window window
   mod_signal=qam/(max(abs(qam)+0.001));
   ts_mod=ts_mod/(max(abs(ts_mod)+0.001));


mod_signal_length = length(mod_signal)/fs; % Length of modulated signal in seconds
if (nr_blocks==1)
fprintf('Raw data rate: %g kbps\n Info rate: %g kbps \n',L/(mod_signal_length*1000),Nb/(mod_signal_length*1000))
end
%% Receiver

if(loops)
    fc = 2491:1:2493;
    order=12:1:14;
    eq_g=5.2:0.2:6;
    alfa = 2.5:0.05:2.6;
    t_block = [0.01 0.02];
    fchard=10500:500:12000;
else
    fc=2491;
    order=12;
    eq_g=5.2;
    alfa =2.55;
    t_block = 0.02;
    fchard = 11000;
end
%% AWGN channel
%rcvd=[zeros(1,randi(500,1)), mod_signal];
rcvd=[mod_signal];
rcvd_no=awgn(rcvd,SNR(SNR_index),'measured'); %scale
%%
ro = rcvd_no' ;
no_iterations = length(fc)*length(order)*length(eq_g)*length(alfa)*length(t_block)*length(fchard);
min_var=1e6;

tic
for(k_fc=1:length(fc))
    for(k_o=1:length(order))
        for(k_eq=1:length(eq_g))
            for(k_alfa=1:length(alfa))
                for(k_t=1:length(t_block))
                    for(k_fchard=1:length(fchard))
                        close all
                        
                        %% Filter
                        %r=peakEQ(ro,eq_g(k_eq))';
                        r=ro;
                        %%
                        
                        [t_samp ref]=synch(r,ts_mod,n_sym,plotting,1);
                        
                        r=r';
                        r=r(t_samp:end);
                        
                        if(plotting)
                            figure(2)
                            subplot(2,2,1)
                            pwelch(mod_signal)
                            title('Transmitted signal')
                            subplot(2,2,2)
                            pwelch(r)
                            title('Received signal')
                        end
                        
                        if(continuous)
                            t=0:1/fs:length(r)/fs-1/fs;
                            Vnx=r.*cos(2*pi*f1*t);
                            Vny=-r.*sin(2*pi*f1*t);
                            Vnx=Vnx(1:n_sym*(length(data)/(2*levels)+ts_length+20));
                            Vny=Vny(1:n_sym*(length(data)/(2*levels)+ts_length+20));
                        else
                            Vnx=[];
                            Vny=[];
                            v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs); %vector containing data for 1 period.
                            % Demodulation of received signal
                            for(k=1:(Nb_enc)/(2*levels)+ts_length+100)
                                Vnx=[Vnx, r((k-1)*n_sym+1:k*n_sym).*cos(f1*v)];
                                Vny=[Vny r((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v)];
                            end
                        end
                        
                        Hd=lpf(order(k_o),fc(k_fc),alfa(k_alfa));
                        
                        Hx=2.*filter(Hd,Vnx);
                        Hy=2.*filter(Hd,Vny);
                        Hd=lpfhard(fchard(k_fchard));
                        Hx=2.*filter(Hd,Hx);
                        Hy=2.*filter(Hd,Hy);
                        ML = length (Hx);
                        
                        
                        
                        
                        
                        margin=100;
                        r_filt=[];
                        for(k=1:n_sym*(ts_length+2*margin))
                            r_aux= Hx(k) + Hy(k)*1i;
                            r_filt = [r_filt r_aux];
                        end
                        
                        n_samp = synch2(r_filt(1:(ts_length+2*margin)*n_sym),mconst_ts,n_sym);
                        
                        mconst=[];
                        
                        for m=n_samp:n_sym:ML
                            Haux = Hx(m) + Hy(m)*1i;
                            mconst = [mconst Haux];
                        end
                        
                        
                        [phihat ref ref_re ref_im]=phase_estimation(mconst,mconst_ts);
                        %scatterplot(mconst*exp(-1i*phihat) / ref),grid
                        
                        % mconst_skewed = real (mconst(1:length(mconst_ts))*exp(-1i*phihat) /ref_re) + 1i* imag(mconst(1:length(mconst_ts))*exp(-1i*phihat) /ref_im);
                        %gama = skew_estimation(mconst_skewed ,mconst_ts);
                        batch_length=floor(t_block(k_t)/Ts);
                        mdem=[];
                        mconstdem=[];
                        ref2=1;
                        
                        mconst_skew=[];
                        variance=0;
                        for(k=1:floor(length(mconst)/batch_length))
                            mconst_phi = real(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2) + 1i*imag(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2);
                            mconstdem =[mconstdem mconst_phi];
                            
                            
                            for q=1:length(mconst_phi)
                                Hx(q)=real(mconst_phi(q));
                                Hy(q)=imag(mconst_phi(q));
                                
                                %                         Hys(q)=Hy(q) / cos(gama);
                                %                         Hxs(q)=Hx(q)+Hys(q)*sin(gama);
                                
                            end
                            %                     mconst_skew = [mconst_skew Hxs(1:length(mconst_phi))+1i*Hys(1:length(mconst_phi))];
                            
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
                                aux=demod(fliplr(sym),levels,A);
                                aux=(Hx(m)-real(aux)).^2+(Hy(m)-imag(aux)).^2;
                                variance=variance+aux;
                            end
                            
                            if(mod(length(mdem),batch_length)==0)
                                demconst=demod(mdem((k-1)*batch_length*2*levels+1:k*batch_length*2*levels),levels,A);
                                [theta ref2]=offset_estimation(mconst_phi,demconst);
                                
                                phihat=phihat+theta;
                                ref2=1;
                            end
                        end
                        
                        k=k+1;
                        mconst_phi = mconst((k-1)*batch_length+1:end) * exp(-1i*phihat) / (ref*ref2);
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
                            aux=demod(fliplr(sym),levels,A);
                            aux=(Hx(m)-real(aux)).^2+(Hy(m)-imag(aux)).^2;
                            variance=variance+aux;
                        end
                        
                        
          %                           scatterplot(mconstdem),grid
                        %             scatterplot(mconst_skew),grid
                        
                        test =[ts; data];
                        decoded=mdem;
                        dec_data=decoded(ts_length*2*levels+1:ts_length*2*levels+Nb_enc);
                        %% Coding
                        [conv_dec,Nb_dec]=convdecode(dec_data,char(cr(coderate)));
                        conv_dec=conv_dec';
                        if(Nb_dec>Nb)
                         conv_dec=conv_dec(1:Nb);
                         warning('sizes changed');
                        end
                        variance;
                        
                        %scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
                        if(length(conv_dec)+ts_length*2*levels>=length(test))
                            conv_dec=conv_dec(1:length(test)-ts_length*2*levels);
 %                           if(plotting) stem(test' ~= conv_dec); end
                            errors2=sum(conv_dec~=data);
                            %errors = sum(test(length(ts)+1:end)' ~= conv_dec(ts_length*2*levels+1:end));
                            
                            %BER = errors2 / length(test(length(ts)+1:end)) * 100;
                          
                        else
                            error('length(conv_dec)+ts_length*2*levels not greater than length(test)');
                        end
                        no_iterations=no_iterations-1;
                    end
                end
            end
        end
    end
end
end
nr_errors(SNR_index) = nr_errors(SNR_index) + errors2;
BER2 = nr_errors(SNR_index) / Nb / nr_blocks;
BERD(SNR_index)=BER2;
if(nr_blocks==1)
fprintf('BER: %g \n',BER2);
end
fprintf('Eb/N0: %.0f \n',EbN0(SNR_index));

end

end
fprintf('BER: %g \n',BER2)
figure(1)
semilogy(EbN0,BERD,'r','LineWidth',1.5);

%semilogy(EbN0,BERD(:,end),'r','LineWidth',1.5);
hold on
%M=4.^(1:5);
M=4^levels;
BERt=zeros(length(M),length(EbN0));
for(indM=1:length(M))
  BERt(indM,:)=berawgn(EbN0,'qam',M(indM));
end
semilogy(EbN0,BERt(1,:),...
         'LineWidth',1.5);
xlabel('E_b/N_0 [dB]'); ylabel('BER');
title('M-QAM error probability');
%legend('M=4','M=16','M=64','M=256','M=1024');
legend(' 256-QAM','Theoretical 256-QAM');

grid on;
axis([0 30 10e-7 1]);
