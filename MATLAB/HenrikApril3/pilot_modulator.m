function [mod_pilot,mod_tsequence] = pilot_modulator(tsequence,Nb,gb_length,Tb,fs,f1,f2)
%MOD_PILOT Modulates a pilot signal containing guard bits, training
%sequence and length of data.

number_of_datalength_bits = 17; % Number of bits for representing length of data

guard_bits = round(rand(1,gb_length));

data_length = dec2bin(Nb)-'0'; % Length of data in binary format
data_length = [zeros(1,number_of_datalength_bits - length(data_length)) data_length];

pilot_bits = [guard_bits tsequence data_length];


%Modulation
nr_samples_bit = Tb*fs;
window=hann(nr_samples_bit);
delta=10;
mod_pilot=[];
tx_short=[];
pulse=[];
for(k=1:length(pilot_bits))
    b=pilot_bits(k);
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

mod_pilot = mod_pilot/(max(abs(mod_pilot)+0.01);

k_tsequence_start = nr_samples_bit*gb_length + 1;
k_tsequence_end = k_tsequence_start + nr_samples_bit*length(tsequence);


mod_tsequence = mod_pilot(k_tsequence_start:k_tsequence_end);



end

