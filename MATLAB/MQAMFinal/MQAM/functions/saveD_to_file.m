function [  ] =saveD_to_file( filename, data, L )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
fileID = fopen(filename,'w');
 fprintf(fileID,'%d\n',L);
for(k=1:length(data))
    fprintf(fileID,'%f\n',data(k));
end

fclose(fileID);



end

