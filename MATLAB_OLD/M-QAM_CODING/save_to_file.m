function [] = save_to_file( gb,ts,data,levels )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


fileID = fopen('gb_test.txt','w');
 fprintf(fileID,'%d\n',length(gb)/(2*levels));
for(k=1:length(gb))
    fprintf(fileID,'%d\n',gb(k));
end

fclose(fileID);





fileID = fopen('ts_test.txt','w');
 fprintf(fileID,'%d\n',length(ts)/(2*levels));
for(k=1:length(ts))
    fprintf(fileID,'%d\n',ts(k));
end

fclose(fileID);



fileID = fopen('data_test.txt','w');
 fprintf(fileID,'%d\n',length(data));
for(k=1:length(data))
    fprintf(fileID,'%d\n',data(k));
end

fclose(fileID);

end



