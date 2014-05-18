function copy_file_to_all( filename )
%
% function copy_file_from_sdcard_to_working_directory( filename )
%
% The name of this file should explain what it does.
%
% Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
% This software is provided  ’as is’. It is free to use for non-commercial purposes.
% For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
% for a license. For non-commercial use, we appreciate citations of our work,
% please contact, Per Zetterberg (per.zetterberg@ee.kth.se),
% for how information on how to cite.
cmd_str=['adb devices'];
[ans,output] = system(cmd_str);

C =strsplit(output);
phone=[];
count=0;
for(k=1:length(C))
    if(strcmp(C(k),'device'))
        fprintf('Found device %s\n',C{k-1});
        phone = [phone; C(k-1)];
        count = count+1;
    end
end

if(count>0)
    for(k=1:count)
        cmd_str=['adb -s',' ', phone{k},' push ',filename,' /sdcard/',filename];
        system(cmd_str);
    end
else
    disp('Found no device plugged ! ');
end
%
% output = textscan(output,'%s %s %s');
% output{1}{3}
% output{1}{4}
%
% cmd_str=['adb -s',' ', output{1}{4},' push ',filename,' /sdcard/',filename];
%
% cmd_str=['adb -s',' ', output{1}{3},' push ',filename,' /sdcard/',filename];
% system(cmd_str);

end


