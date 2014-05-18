function list = list_log(time0,id)
%
% function list = list_sensor_log_files_on_sdcard(time0)
%
% This function returns a list of the sensorlog filenames in 
% the cell array "list.filenames". The age of the file list{i1}
% is contained in list.etime(i1). The age is given as the number
% of seconds since time0. If no time0 is provided as input to the
% function it is set to 00.00.00 the first of january 2010. 
%
%
% Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
% This software is provided  ?as is?. It is free to use for non-commercial purposes.
% For commercial purposes please contact Peter H?ndel (peter.handel@ee.kth.se)
% for a license. For non-commercial use, we appreciate citations of our work,
% please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
% for how information on how to cite.

    
    %if ~exist('time0')
        time0=[2010,1,1,0,0,0];
    %end;
    cmd_str =['adb -s ',id,' shell ls sdcard/'];
    [status,str]=system(cmd_str);
    start_index=strfind(str,'sensorlog');
    stop_index=strfind(str,'.csv');
    for i1=1:length(start_index)
        tmpstr=str(start_index(i1):(stop_index(i1)+3));
        list.filenames{i1}=tmpstr;
        time(1)=str2num(tmpstr(10:13));
        time(2)=str2num(tmpstr(14:15));
        time(3)=str2num(tmpstr(16:17));
        time(4)=str2num(tmpstr(18:19));
        time(5)=str2num(tmpstr(20:21));
        time(6)=0;
        list.etimes(i1)=etime(time,time0);
    end;
end

