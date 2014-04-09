function list = list_video_recordings_on_sdcard(time0)
%
% function list = list_recordings_on_sdcard(time0)
%
    if ~exist('time0')
        time0=[2010,1,1,0,0,0];
    end;
    [status,str]=system('adb shell ls sdcard/recordings/');
    str
    start_index=strfind(str,'video');
    stop_index=strfind(str,'.rec');
    for i1=1:length(start_index)
        tmpstr=str(start_index(i1):(stop_index(i1)+3))
        list.filenames{i1}=tmpstr;
        time(1)=str2num(tmpstr(6:9));
        time(2)=str2num(tmpstr(10:11));
        time(3)=str2num(tmpstr(12:13));
        time(4)=str2num(tmpstr(14:15));
        time(5)=str2num(tmpstr(16:17));
        time(6)=0;
        list.etimes(i1)=etime(time,time0);
    end;
end


