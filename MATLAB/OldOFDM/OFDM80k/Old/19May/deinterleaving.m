function s = deinterleaving(r,n,m)

%r: input signal
%s: output signal
%n: number of rows in the interleaving matrix
%m: number of colums in the interleaving matrix

% ------- deinterleaving.m -----------------------------------
% Black team
% April-11-05
% ----------------------------------------------------------


Lr = length(r);   % size of the input signal
Li = m*n;         % size of the interleaver

IM = zeros(n,m);
s=zeros(size(r));

K = floor(Lr/Li);

for k = 1:K
    for i = 1:m
        IM(:,i)=r( ((k-1)*m+i-1)*n+1 : ((k-1)*m + i)*n);   % we fill the deinterleaver column by column
    end
    for i = 1:n
        s(((k-1)*n+i-1)*m+1 : ((k-1)*n + i)*m) = IM(i,:);  % we empty the deinterleaver row by row
    end
end

s(K*n*m+1:end)=r(K*n*m+1:end);				   % we keep the last bits unchanged