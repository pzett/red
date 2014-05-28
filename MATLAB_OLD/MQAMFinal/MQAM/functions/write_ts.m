%%
ts_length=1000;
levels=3;
ts = randint(ts_length*2*levels,1,2);

fileID = fopen('ts2.txt','w');

for(k=1:length(ts))
    fprintf(fileID,'%d\n',ts(k));
end

fclose(fileID);