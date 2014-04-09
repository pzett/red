function [ tx_signal ] = MFSKwindow_modulation(data,fs,f,Tb,gb_length,t,tsequence,M,ref)

op_buffer=100000; %size of storage buffer.After this, the sync is run again
data_length=length(data); %Length of data in bits

nr_samples_bit=floor(t*fs); %excludes guard period
nr_samples_period=floor(Tb*fs);%includes guard period
gband = round(rand(1,gb_length));%generate guard band randomly

if data_length>op_buffer
      warning('MFSK Modulation bits will be encoded this way: guard_band/ts/data/ts/data/guard_band');
    bit_stream=[gband,tsequence,data(1:op_buffer),tsequence,data(op_buffer+1:data_length),gband];
else
    bit_stream = data; %bit_stream=[gband tsequence length data];    
end


window=rectwin(nr_samples_bit); %define window.
%trunc = 1;
%window = root_raised_cosine((nr_samples_bit-1)/(2*trunc),0.22,trunc);
delta=10;


%Modulation
tx_signal=[]; %allocate variables needed for modulation
tx_temp=[];
tx_short=[];
tx_guard=zeros(1,floor(Tb*fs)-floor(t*fs));
pulse=[];
symbol=zeros(1,2);
amp=0;
for j=1:log2(M)+1:(length(bit_stream))
    
    symbol_b=(bit_stream(j:j+log2(M))); %grab 2 bits for symbol
    symbol_d1=bi2de(symbol_b(1:2),'left-msb'); %convert bits to decimal.
    symbol_d2=bi2de(symbol_b(3:4),'left-msb'); %convert bits to decimal.
    switch symbol_d1 %choose where to send it.
        case 0
            fn = [(f(1)-delta)*2/fs (f(1)+delta)*2/fs];
        case 2
            fn = [(f(2)-delta)*2/fs (f(2)+delta)*2/fs];
        case 3
            fn = [(f(3)-delta)*2/fs (f(3)+delta)*2/fs];
        case 1 
            fn = [(f(4)-delta)*2/fs (f(4)+delta)*2/fs];
    end
     switch symbol_d2 %choose where to send it.
        case 0
            amp = 4*ref/4;
        case 2
            amp = 3*ref/4;
        case 3
            amp=  2*ref/4;
        case 1 
            amp=  1*ref/4;
    end
    pulse=fir1(nr_samples_bit-1,fn,window);
    tx_temp = amp*ones(1,nr_samples_bit);
    tx_short = tx_temp .* pulse;
    tx_temp = [tx_short tx_guard];
    tx_signal=[tx_signal tx_temp];
    pulse=0;    
end

tx_signal = tx_signal / (max(abs(tx_signal))+0.0001);


end

