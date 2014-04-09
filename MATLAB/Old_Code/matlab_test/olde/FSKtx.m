

% Define the two frequencies 
% Frequency component for bit 1
f1 = 2500+2*fs/88; 
% Frequency component for bit 0 
f2 = 2500;

gb_length=10; %length of guard band
ts_length=20; %length of training sequence
guard=round(rand(1,gb_length)); %generate guard band
tsequence=round(rand(1,ts_length)); %generate tsequence
save('tsequence.mat','tsequence');
bit_stream = [guard tsequence data]; %merge the bits together


t = 0 : 1/fs : Tb-1/fs;%time for one bit
FSK_signal = []; %Signal to transmit

for ii = 1:length(bit_stream)
    
    FSK_signal = [FSK_signal (bit_stream(ii)==1)*cos(2*pi*f1*t)+...
                             (bit_stream(ii)==0)*cos(2*pi*f2*t)    ];
                         
end



