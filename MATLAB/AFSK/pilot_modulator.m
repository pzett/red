function [mod_pilot,mod_tsequence ref] = pilot_modulator(tsequence,Nb,gb_length,Tb,fs,f1,f2,f3,f4,d_length)
%Modulates a pilot signal containing guard bits, training
%sequence and length of data.

guard_bits = round(rand(1,gb_length));

data_length = dec2bin(Nb)-'0'; % Length of data in binary format
data_length = [zeros(1,d_length - length(data_length)) data_length];


%Modulation of pilot signal 
nr_samples_bit = Tb*fs; %Number of samples per bit.
window=rectwin(nr_samples_bit);%Window to be used to modulate tsequence
delta=10; %half of wide bandpass filter to be implemented in pulse shaping

mod_pilot=[]; %allocate variables
tx_short=[];
pulse=[];

%% Guard bits
for(k=1:length(guard_bits))
    b=guard_bits(k);
    switch b
        case 0
            fn = [(f2-delta)*2/fs (f2+delta)*2/fs]; %f2 modulates bit 0
        case 1
            fn = [(f1-delta)*2/fs (f1+delta)*2/fs]; %f1 modulates bit 1
    end
    pulse=fir1(nr_samples_bit-1,fn,window); %apply window to pulse centered
    tx_temp = ones(1,nr_samples_bit);       %in fn (in frequency domain)
    tx_short = tx_temp .* pulse;
    mod_pilot=[mod_pilot tx_short]; %concatenate
    pulse=0;
end

%% Training sequence
for(k=1:length(tsequence))
    b=tsequence(k);
    switch b
        case 0
            fn = [(f4-delta)*2/fs (f4+delta)*2/fs];
        case 1
            fn = [(f3-delta)*2/fs (f3+delta)*2/fs];
    end
    pulse=fir1(nr_samples_bit-1,fn,window);
    tx_temp = ones(1,nr_samples_bit);
    tx_short = tx_temp .* pulse;
    mod_pilot=[mod_pilot tx_short];
    pulse=0;
end

%% Data length
for(k=1:length(data_length))
    b=data_length(k);
    switch b
        case 0
            fn = [(f2-delta)*2/fs (f2+delta)*2/fs];
        case 1
            fn = [(f1-delta)*2/fs (f1+delta)*2/fs];
    end
    pulse=fir1(nr_samples_bit-1,fn,window);
    tx_temp = ones(1,nr_samples_bit);
    tx_short = tx_temp .* pulse;
    mod_pilot=[mod_pilot tx_short];
    pulse=0;
end


%%


mod_pilot = mod_pilot/(max(abs(mod_pilot)+0.0001));%normalize for wav playin'
                                                
                                                 %%sample where tsequence
                                                
k_tsequence_start = nr_samples_bit*gb_length + 1;%starts                                                    
k_tsequence_end = k_tsequence_start + nr_samples_bit*length(tsequence);%end

mod_tsequence = mod_pilot(k_tsequence_start:k_tsequence_end);
ref=max(mod_tsequence);


end

