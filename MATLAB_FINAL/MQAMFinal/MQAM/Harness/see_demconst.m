fileID = fopen('demconst.txt','r');
formatSpec = '%f';
data = fscanf(fileID,formatSpec);
L=data(1);
mconst=zeros(L,1);
for(k=2:L+1)
    mconst(k-1) = data(k);
end
mreal=mconst(1:2:end-1)
mimag=mconst(2:2:end)

mconst=mreal+1i*mimag;

scatterplot(mconst); grid on