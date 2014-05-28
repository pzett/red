%%
ts_length=2000;
levels=3;
ts = randint(ts_length*2*levels,1,2);

fileID = fopen('ts3.txt','w');

for(k=1:length(ts))
    fprintf(fileID,'%d\n',ts(k));
end

fclose(fileID);