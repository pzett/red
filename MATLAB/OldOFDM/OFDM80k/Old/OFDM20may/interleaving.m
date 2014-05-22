function s = interleaving(r,n,m)

%r: input signal
%s: output signal
%n: number of rows in the interleaving matrix
%m: number of colums in the interleaving matrix

% ------- interleaving.m -----------------------------------
% Black team
% April-11-05
% ----------------------------------------------------------

Lr = length(r);   % size of the input signal
Li = m*n;        % size of the interleaver

IM = zeros(n,m);
s=zeros(size(r));

K = floor(Lr/Li);

for k = 1:K
    for i = 1:n
        IM(i,:)=r( ((k-1)*n+i-1)*m+1 : ((k-1)*n + i)*m);     % we fill the interleaver row by row
    end
    for i = 1:m
        s(((k-1)*m+i-1)*n+1 : ((k-1)*m + i)*n) = IM(:,i);    % we empty the interleaver column by column
    end
end

s(K*n*m+1:end)=r(K*n*m+1:end);			  	     % we keep the last bits unchanged