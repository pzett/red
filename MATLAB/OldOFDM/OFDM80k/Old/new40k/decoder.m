function [ mdem,mconstdem ] = decoder(levels,asym, batch_length,high,phihat,...
    ref,decoded,pilot,ts_length,Nc,A )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
ref2 = 1; % variable to keep track of amplitude changes in time, might not be needed.
if(asym)
    if(rem(high,batch_length) ~= 0 || rem(Nc-high,batch_length) ~= 0 )
        disp('You might want to reconsider your batch length.');
    end
else
    if(mod(Nc/2,batch_length) ~= 0);
        disp('You might want to reconsider your batch length.');
    end
    %if(mod(pilot_int/(2*levels),batch_length) ~= 0 && pilot); disp('Pilot interval and batch length should match !'); pause; end
end
%initialize variables for decoding
mconst = transpose(decoded);
mconstdem = [];
mdem = [];
if(pilot); trigger_pilots = 0;  pilot_index=1; end;


for(k=1:floor(length(mconst)/batch_length))
    
    %     for(b=1:batch_length)
    %         mconst_phi(b) = mconst((k-1)*batch_length+b) * exp(-1i*phihat(b)) / (ref(b)*ref2);
    %     end
    
    mconst_phi=zeros(1,batch_length);
    
    for(b=0:batch_length-1)
        index = (k-1)*batch_length+b; % auxiliary variable so that the right phase and amplitude estimations are used.
        
        mconst_phi(b+1) = mconst(index+1) * exp(-1i*phihat(mod(index,Nc)+1)) / (ref(mod(index,Nc)+1)*ref2);
    end
    % plot(real(mconst_phi(b+1)),imag(mconst_phi(b+1)),'.');
    % mconst_phi = real(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2) + 1i*imag(mconst((k-1)*batch_length+1:k*batch_length) * exp(-1i*phihat)) / (ref*ref2);
    mconstdem =[mconstdem mconst_phi];
    
    for q=1:length(mconst_phi) % take real and imag. part of constellation to apply ML decision
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
    
    [theta ref2]=offset_estimation(mconst_phi,demconst); %estimate the phase offset.
    ref2=1; % do not change amplitude, assume it is time invariant
    
    for(b=0:batch_length-1)
        index = (k-1)*batch_length+b;
        
        phihat(mod(index,Nc)+1) = phihat(mod(index,Nc)+1) + theta;
        %phihat=phihat+theta;
    end
    
    if(pilot) %if pilots are being used
        if(length(mconstdem) == ts_length); trigger_pilots = 1; end
        
        if(mod(length(mconstdem) - ts_length, pilot_int / (2*levels) )==0 && trigger_pilots && ((length(mconstdem)-ts_length) ~= 0) )
            if(pilot_index < size(pilot_phase,2))
                (length(mconstdem)-ts_length)
                phihat = pilot_phase(:,pilot_index); %new phase estimation
                %  ref = pilot_ref(:,pilot_index);      %new amplitude estimation
                pilot_index=pilot_index+1
            end
        end
    end
end
hold off

k=k+1; %process last batch.
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

end

