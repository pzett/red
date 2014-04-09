function [ tx_signal ] = MFSKwindow_modulation( data, fs,f,Tb,gb_length,t,tsequence)

op_buffer=4096; % size of storage buffer. After this, we will run the sync again
data_length=length(data);

nr_samples_bit=floor(t*fs);
nr_samples_period=floor(Tb*fs);
gband = round(rand(1,gb_length));

if data_length>op_buffer
      warning('Bits will be encoded this way: guard_band/ts/data/ts/data/gband');
    bit_stream=[gband,tsequence,data(1:op_buffer),tsequence,data(op_buffer+1:data_length),gband];
else
    bit_stream=[gband tsequence data];    
end


window=hann(nr_samples_bit);
delta=10;

M = length(f);
%Modulation
tx_signal=[];
tx_temp=[];
tx_short=[];
tx_guard=zeros(1,floor(Tb*fs)-floor(t*fs));
pulse=[];
symbol=zeros(1,2);
for j=1:log2(M):(length(bit_stream))
    symbol_b=[bit_stream(j) bit_stream(j+1)];
    symbol_d=bi2de(symbol_b,'left-msb');
    switch symbol_d
        case 0
            fn = [(f(1)-delta)*2/fs (f(1)+delta)*2/fs];
        case 2
            fn = [(f(2)-delta)*2/fs (f(2)+delta)*2/fs];
        case 3
            fn = [(f(3)-delta)*2/fs (f(3)+delta)*2/fs];
        case 1 
            fn = [(f(4)-delta)*2/fs (f(4)+delta)*2/fs];

    end
    pulse=fir1(nr_samples_bit-1,fn,window);
    tx_temp = ones(1,nr_samples_bit);
    tx_short = tx_temp .* pulse;
    tx_temp = [tx_short tx_guard];
    tx_signal=[tx_signal tx_temp];
    pulse=0;    
end

tx_signal = tx_signal / (max(abs(tx_signal))+0.01);


end

