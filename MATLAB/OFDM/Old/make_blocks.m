function [block] = make_blocks(tx_sig,N) % make blocks of size N
%Usage- [block] = make_blocks(tx_sig,N) %Input-
%    tx_sig = the signal whose blocks have to be made
%    N = size of each block
%Output-
%    blocks = Matrix of blocks
no_of_blocks = ceil(length(tx_sig)/N);
% If the size of the block is not an integer multiple of size of eack block then padd with zeros
if (mod(length(tx_sig),N) ~= 0)
no_of_zeros = no_of_blocks*N - length(tx_sig); % Find the number of zeros to be inserted
tx_sig = [tx_sig;zeros(no_of_zeros,1)]; % Do zero padding 
end

block = reshape(tx_sig,N,no_of_blocks);

end

