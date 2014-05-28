
window_length = 8;

win = gausswin(window_length);

fileID = fopen('window8.txt','w');
fprintf(fileID,'%d\n',length(win))
for(k=1:length(win))
    fprintf(fileID,'%1.10f\n',win(k));
end
fclose(fileID);