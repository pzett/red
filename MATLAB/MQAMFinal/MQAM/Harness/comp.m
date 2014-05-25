function [ mconst_outML ] = comp()
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
% fileID = fopen('decision.txt','r');
% formatSpec = '%f';
% data = fscanf(fileID,formatSpec);
% L=data(1);
% decision=zeros(L,1);
% for(k=2:L+1)
%     decision(k-1) = data(k);
% end
% 
% fileID = fopen('data_test.txt','r');
% formatSpec = '%f';
% data = fscanf(fileID,formatSpec);
% L=data(1);
% bits=zeros(L,1);
% for(k=2:L+1)
%     bits(k-1) = data(k);
% end
% 
% stem(bits~=decision(1:length(bits)))
close all
fileID = fopen('bit_buffer.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
sent=zeros(L,1);
for(k=2:L+1)
    sent(k-1) = data(k);
end

fileID = fopen('received.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
rx=zeros(L,1);
for(k=2:L+1)
    rx(k-1) = data(k);
end
stem(rx(3*768+1:3*768+length(sent))~=sent)


fileID = fopen('demconst.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
mconst=zeros(L,1);
for(k=2:L+1)
    mconst(k-1) = data(k);
end


mreal=mconst(1:2:end-1);
mimag=mconst(2:2:end);
mconst=mreal+1i*mimag;

scatterplot(mconst); grid on
Hx=real(mconst)
Hy = imag(mconst)
levels = 3; A=1;
mdem=[];
    for m=1:length(mconst)
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
    
    
%stem(bits~=decision(1:length(bits)))