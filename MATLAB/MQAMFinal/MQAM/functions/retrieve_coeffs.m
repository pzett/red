function [] = retrieve_coeffs( H )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

coeffs = H.numerator;
L=length(coeffs)
fileID = fopen('coeffslpf.txt','w');
fprintf(fileID,'%d\n',L);
for(k=1:L)
    fprintf(fileID,'%1.10f\n',coeffs(k));
end

fclose(fileID);
end

