

fileID = fopen('Vx.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
Vx=zeros(L,1);
for(k=2:L+1)
    Vx(k-1) = data(k);
end


fileID = fopen('Vy.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
Vy=zeros(L,1);
for(k=2:L+1)
    Vy(k-1) = data(k);
end


loops=1;
plotting=1;
for(k_fc=1:length(fc))
    for(k_o=1:length(order))
        for(k_eq=1:length(eq_g))
            if(loops)
                fc =2800:50:3200;
                order=10:1:14;
                eq_g=5.6:0.2:6.6;
            else
                fc=3150;
                order=12;
                eq_g=5.8;
            end
            
            Hd=lpf(order(k_o),fc(k_fc));
            Hx=2.*filter(Hd,Vx);
            Hy=2.*filter(Hd,Vy);
            ML = length (Hx);
            mconst = Hx + 1i*Hy;
            if(plotting) scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Received Constellation'); end
            
            pause
            
            r_filt=[];
            parfor(k=1:n_sym*(ts_length+2*margin))
                r_aux= Hx(k) + Hy(k)*1i;
                r_filt = [r_filt r_aux];
            end
            
            
            n_samp = synch2(r_filt(1:(ts_length+2*margin)*n_sym),mconst_ts,n_sym);
            
            mconst=[];
            
            for m=n_samp:n_sym:ML
                Haux = Hx(m) + Hy(m)*1i;
                mconst = [mconst Haux];
            end
            
        end
    end
end
