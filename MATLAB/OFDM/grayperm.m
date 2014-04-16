function [grayperm]=grayperm(d);
%Gives the gray permutation for a given constalltion size
%Usage- [grayperm]=grayperm(d)
%Inputs- d = symbolsize in bits = log2(M) where M is the constallation size
%Outputs- grayperm= the permuted array
 grayperm=[0];
if d<1
    grayperm=[0];
end
if d==1
    grayperm=[0 1];
else
    grayperm=[0 1 3 2];
end
ind=2;
a=grayperm;
while d-ind>0
     ind=ind+1;
     b=fliplr(a);
     a=[a,(b+2^(ind-1))];
end
grayperm=a;

end

