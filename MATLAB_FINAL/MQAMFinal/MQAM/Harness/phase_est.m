function [ mconst_outML ] = phase_est( )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
fileID = fopen('Hx.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
Hx=zeros(L,1);
for(k=2:L+1)
    Hx(k-1) = data(k);
end

fileID = fopen('Hy.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
Hy=zeros(L,1);
for(k=2:L+1)
    Hy(k-1) = data(k);
end

fileID = fopen('ts_real.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
ts_real=zeros(L,1);
for(k=2:L+1)
    ts_real(k-1) = data(k);
end

fileID = fopen('ts_imag.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
ts_imag=zeros(L,1);
for(k=2:L+1)
    ts_imag(k-1) = data(k);
end


r=Hx+1i*Hy;
b_train_qam = ts_real + 1i*ts_imag;
size_b=length(b_train_qam);
arg_sum=0;
ref=0;
%estimate the phase shift based on known train sequence

for i=1:size_b
    
    x=(r(i))*(conj(b_train_qam(i)));
   
    
   % ref=(ref+abs(r(i))/abs(b_train_qam(i)))/size_b(2);
    argx=angle(x);
    
    arg_sum=arg_sum+argx;
    aux=abs(r(i))/abs(b_train_qam(i));
    ref=ref+aux;
    
end



ref=ref/size_b
phihat=arg_sum/size_b


 
 fileID = fopen('out_real.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
mconst_outrJ=zeros(L,1);
for(k=2:L+1)
    mconst_outrJ(k-1) = data(k);
end

 fileID = fopen('out_imag.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
mconst_outiJ=zeros(L,1);
for(k=2:L+1)
    mconst_outiJ(k-1) = data(k);
end

mconst_outJ=mconst_outrJ+1i*mconst_outiJ;
mconst_outML = r(size_b+1:end) * exp(-1i*phihat) / (ref);

mconst_outJ(1:10)
mconst_outML(1:10)
 

end

