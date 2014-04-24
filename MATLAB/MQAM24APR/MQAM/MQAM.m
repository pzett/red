%MQAM

%Set up variables and workspace.
close all;
clear;
clc;
fclose('all');
%Initialize variables
fs=44100; %Sampling frequency
Nb=1000; %Number of bits to transmit
SNR = 90;

levels = 2;

left = rem(Nb,2*levels);

data = randint(Nb+(2*levels-left),1,2);

L=length(data);

f1=12000;

n_bit=25;
n_sym=n_bit*2*levels;
%n_bit = n_sym/(2*levels);
Ts=n_sym/fs;



symbol=ones(1,n_sym);

mx=[];my=[];

x=0;
y=0;

% We create groups of 2M bits to modulate
for n=0:2*levels:L-2*levels
    bit=[];
    xi=0;
    yi=0;
    
    for m= 1:2:2*levels
        if data(n+m)==0      
            xi=xi+(2^((m-1)/2));
            
        else
            xi=xi-(2^((m-1)/2));
            
        end
        if data(n+m+1)==0
            yi=yi+(2^((m-1)/2));
            
        else
            yi=yi-(2^((m-1)/2));
            
        end
    end
    
    x=xi*symbol;
    y=yi*symbol;
    % We store the generated symbol with the calculated amplitude inside mx and
    % my variables. We update the mbit string with the last 2M modulated bits.
    mx=[mx x];
    my=[my y];
    
    
end

v=0:2*pi/fs:2*pi*(n_sym/fs-1/fs);


mconst = mx + my*1i;
qam=[];
for(k=1:length(data)/(2*levels))
qam=[qam real(mconst((k-1)*n_sym+1:k*n_sym)).*cos(f1*v)-imag(mconst((k-1)*n_sym+1:k*n_sym)).*sin(f1*v)];
end
scatterplot(mconst),grid,xlabel('I'),ylabel('Q'),title('Constellation before sending');


Vn=awgn(qam,SNR,'measured');

Vnx=[];
Vny=[];
% Demodulation of received signal
for(k=1:length(data)/(2*levels))
Vnx=[Vnx Vn((k-1)*n_sym+1:k*n_sym).*cos(f1*v)];
Vny=[Vny Vn((k-1)*n_sym+1:k*n_sym).*-1.*sin(f1*v)];
end



[b,a]=butter(2,0.04);
Hx=2.*filter(b,a,Vnx);
Hy=2.*filter(b,a,Vny);
ML=length(Hx);


msync2=[];
for m=n_bit:2*levels*n_bit:ML
    Haux = Hx(m) + Hy(m)*1i;
    msync2 = [msync2 Haux];
end
scatterplot(msync2),grid,xlabel('I'),ylabel('Q'),title('Received Constellation');

mdem=[];
for m=n_bit:2*levels*n_bit:ML
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
        th_y = th_y + i_y*(2^(levels-n));
        th_x =  th_x + i_x*(2^(levels-n));
    end
   
    mdem=[mdem fliplr(sym)];
end

BER=sum(mdem'~=data)/Nb*100





