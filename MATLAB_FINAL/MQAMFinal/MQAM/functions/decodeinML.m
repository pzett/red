load('MQAM.mat')
load('ts_mod.mat')
close all
fileID = fopen('Vx.txt','r');
formatSpec = '%f';
data2 = fscanf(fileID,formatSpec);
L=data2(1);
Vx=zeros(L,1);
for(k=2:L+1)
    Vx(k-1) = data2(k);
end


fileID = fopen('Vy.txt','r');
formatSpec = '%f';
data2 = fscanf(fileID,formatSpec);
L=data2(1);
Vy=zeros(L,1);
for(k=2:L+1)
    Vy(k-1) = data2(k);
end


loops=0;
plotting=0;
save = 0;
if(loops)
    fc =2800:100:3500;
    order=12:1:15;
    eq_g=5.5:0.5:7;
    alfa = 2.5;
else
    fc=2780;
    order=15;
    eq_g=5.2;
    alfa = 2.5;
end
min_var = 1e6;
count_theta =0;
for(k_fc=1:length(fc))
    for(k_o=1:length(order))
        for(k_eq=1:length(eq_g))
            for(k_alfa=1:length(alfa))
                close all
                delete('thetaML.txt')
                
                Hd=lpf(order(k_o),fc(k_fc),alfa(k_alfa));
                Hd.numerator
                Hx=filter(Hd,Vx);
                Hy=filter(Hd,Vy);
                ML = length (Hx);
                
                if (save)
                    saveD_to_file('HxML.txt',Hx ,length(Hx));
                    saveD_to_file('HyML.txt',Hy,length(Hy));
                end
                
                margin=200;
                r_filt=[];
                parfor(k=1:n_sym*(ts_length+2*margin))
                    r_aux= Hx(k) + Hy(k)*1i;
                    r_filt = [r_filt r_aux];
                end
                
                
                n_samp = synch2(r_filt(1:(ts_length+2*margin)*n_sym),mconst_ts,n_sym)
                
                mconst=[];
                
                for m=n_samp:n_sym:ML
                    Haux = Hx(m) + Hy(m)*1i;
                    mconst = [mconst Haux];
                end
                if(plotting) scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Received Constellation'); end
                if(save) saveD_to_file('mconstML.txt',real(mconst),length(mconst(ts_length+1:end))); end
                
                
                [phihat ref ref_re ref_im]=phase_estimation(mconst,mconst_ts)
                if(save)
                    saveD_to_file('phirefML.txt',[phihat ref],2);
                    saveD_to_file('mconstML.txt',real(mconst),length(mconst(ts_length+1:end)));   
                end
                
                
                batch_length=floor(0.1/Ts);
                if(save)
                    saveD_to_file('batch_length.txt',batch_length,length(batch_length));
                    saveD_to_file('nsamp.txt',n_samp,length(n_samp));
                end
                
                mdem=[];
                mconstdem=[];
                ref2=1;
                
                
                variance=0;
                for(k=1:floor(length(mconst)/batch_length))
                    
                    mconst_phi = real(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2) + 1i*imag(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2);
                    mconstdem =[mconstdem mconst_phi];
                    if(plotting) scatterplot(mconstdem),grid,xlabel('I'),ylabel('Q'),title('Received Constellation'); end
                    
                    for q=1:length(mconst_phi)
                        Hx(q)=real(mconst_phi(q));
                        Hy(q)=imag(mconst_phi(q));    
                    end
                    
                    parfor m=1:length(mconst_phi)
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
                        count_theta=count_theta+1;
                    end
                end
                
                k=k+1;
                mconst_phi = mconst((k-1)*batch_length+1:end) * exp(-1i*phihat) / (ref*ref2);
                mconstdem =[mconstdem mconst_phi];
                parfor q=1:length(mconst_phi)
                    Hx(q)=real(mconst_phi(q));
                    Hy(q)=imag(mconst_phi(q));
                end
                
                parfor m=1:length(mconst_phi)
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
                
                test =[ts; data];
                decoded=mdem;
                
                if(save)
                    saveD_to_file('mconstdemMLx.txt',real(mconstdem),length(mconstdem))
                    saveD_to_file('mconstdemMLy.txt',imag(mconstdem),length(mconstdem))
                end
                
                if(length(decoded)>=length(test))
                    decoded=decoded(1:length(test));
                    if(plotting) stem(test' ~= decoded); end
                    errors = sum(test(length(ts)+1:end)' ~= decoded(length(ts)+1:end));
                    
                    BER = errors / length(test(length(ts)+1:end)) * 100
                    if(BER==0)
                        
                        scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
                        
                        if(variance/length(test(length(ts)+1:end))<min_var)
                            % if(plotting == 0) close all; end
                            scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
                            min_var=variance/length(test(length(ts)+1:end));
                            
                            best_fc=fc(k_fc);
                            best_gain=eq_g(k_eq);
                            best_o=order(k_o);
                            retrieve_coeffs(Hd);
                            
                        end
                        
                    end
                    
                end
                
            end
        end
    end
end
count_theta
best_fc = best_fc
best_o = best_o
best_gain = best_gain
R = 2 * levels / Ts

