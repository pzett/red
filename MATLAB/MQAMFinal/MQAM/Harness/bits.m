L=10002;
fileID = fopen('bits.txt','w');
fprintf(fileID,'%d\n',L);
bit_stream=randint(L,1,2);
for(k=1:L)
    fprintf(fileID,'%d\n',bit_stream(k));
end
fclose(fileID);