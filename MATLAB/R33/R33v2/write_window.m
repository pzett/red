
window_length = 30;

win = hann(window_length);

fileID = fopen('window.txt','w');
fprintf(fileID,'%d\n',length(win))
for(k=1:length(win))
    fprintf(fileID,'%1.7f\n',win(k));
end

fclose(fileID);