


function log_data = get_log_data_from_FrameWork( filename )
%
% This function parses the data in a sensorlog file and assigns it to a
% matlab structure called log_data. Note that the filename must point
% to sensorlog file on the harddisc of the computer (i.e. not the phone).
% The log_data structure contains a field "items" where each item (cell) is
% a measurement. The sensor field of the (cell) define the type of
% measurement. The folowing types exist:
% "S": Sound, "A": Accelerometer, "M" Magnetometer, "P" proximity
% "W": Wifi RSSI, "G": GPS.
%
%
% Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
% This software is provided  ’as is’. It is free to use for non-commercial purposes.
% For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
% for a license. For non-commercial use, we appreciate citations of our work,
% please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
% for how information on how to cite.




    log_data_cntr=0;
    no_sound_samples_in=0;
    no_acc_items=0;
    no_mag_items=0;
    no_prox_items=0;
    no_wifi_items=0;
    no_gps_items=0;
    no_user_items=0;

    fid=fopen(filename,'r');    
           
    string=fgetl(fid);
    while ~(string==-1)
       switch string(1:2)
           case 'S;'
              log_data_cntr=log_data_cntr+1;
               w=findstr(string,';');
               eval(['temp=',string(w(3)+1:end),';']);
               log_data.items{log_data_cntr}.buffer=temp;
               log_data.items{log_data_cntr}.sensor='S';
               no_sound_samples_in=no_sound_samples_in+length(temp);
           case 'C;'
               w=findstr(string,';');
               eval(['temp=',string(w(1)+1:w(2)-1),';']);
               log_data.start_time1=temp;
               eval(['temp=',string(w(2)+1:end),';']);               
               log_data.start_time2=temp;
           case 'A;'
               log_data_cntr=log_data_cntr+1;
               no_acc_items=no_acc_items+1;
               w=findstr(string,';');
               log_data.items{log_data_cntr}.sensor='A';
               log_data.items{log_data_cntr}.time=str2num(string(w(1)+1:w(2)-1));
               log_data.items{log_data_cntr}.x=str2num(string(w(2)+1:w(3)-1));
               log_data.items{log_data_cntr}.y=str2num(string(w(3)+1:w(4)-1));
               log_data.items{log_data_cntr}.z=str2num(string(w(4)+1:end));
           case 'M;'
               log_data_cntr=log_data_cntr+1;
               no_mag_items=no_mag_items+1;
               w=findstr(string,';');
               log_data.items{log_data_cntr}.sensor='M';
               log_data.items{log_data_cntr}.time=str2num(string(w(1)+1:w(2)-1));
               log_data.items{log_data_cntr}.x=str2num(string(w(2)+1:w(3)-1));
               log_data.items{log_data_cntr}.y=str2num(string(w(3)+1:w(4)-1));
               log_data.items{log_data_cntr}.z=str2num(string(w(4)+1:end));
           case 'P;'
               log_data_cntr=log_data_cntr+1;
               no_prox_items=no_prox_items+1;
               w=findstr(string,';');
               log_data.items{log_data_cntr}.sensor='P';
               log_data.items{log_data_cntr}.time=str2num(string(w(1)+1:w(2)-1));
               log_data.items{log_data_cntr}.proximity=str2num(string(w(2)+1:end));
           case 'W;'%% Wifi measuremnent
               log_data_cntr=log_data_cntr+1;
               log_data.items{log_data_cntr}.sensor='W';
               no_wifi_items=no_wifi_items+1;
               wt=findstr(string,'SSID:'); 
               w=[];
               for i1=1:length(wt)
                   if string(wt(i1)-1)~='B'
                       w=[w,wt(i1)];
                   end;
               end;
               no_ap=length(w);
               w=[w,length(string)+1];
               for i1=1:no_ap
                   substr=string(w(i1):(w(i1+1)-1));
                   SSID_start=min(findstr(substr,'SSID:'));
                   BSSID_start=min(findstr(substr,'BSSID:'));
                   capabilities_start=min(findstr(substr,'capabilities:'));
                   level_start=min(findstr(substr,'level:'));
                   frequency_start=min(findstr(substr,'frequency:'));
                   
                   
                   log_data.items{log_data_cntr}.wifi{i1}.SSID=chop_comma_and_on(substr((SSID_start+length('SSID:')):end));
                   log_data.items{log_data_cntr}.wifi{i1}.BSSID=chop_comma_and_on(substr((BSSID_start+length('BSSID:')):end));
                   log_data.items{log_data_cntr}.wifi{i1}.capabilities=chop_comma_and_on(substr((capabilities_start+length('capabilities:')):end));
                   log_data.items{log_data_cntr}.wifi{i1}.level=chop_comma_and_on(substr((level_start+length('level:')):end));
                   log_data.items{log_data_cntr}.wifi{i1}.frequency=chop_comma_and_on(substr((frequency_start+length('frequency:')):end));
                   
                   log_data.items{log_data_cntr}.wifi{i1}.level=str2num(log_data.items{log_data_cntr}.wifi{i1}.level);
                   log_data.items{log_data_cntr}.wifi{i1}.frequency=str2num(log_data.items{log_data_cntr}.wifi{i1}.frequency);

                   
                   
               end;
           case 'G;' %% GPS
               log_data_cntr=log_data_cntr+1;
               log_data.items{log_data_cntr}.sensor='G';
               no_gps_items=no_gps_items+1;
               w=findstr(string,';');
               v=findstr(string,':');
               log_data.items{log_data_cntr}.time=str2num(string((w(1)+1):(w(2)-1)));
               log_data.items{log_data_cntr}.latitude=str2num(string((w(2)+1):(v(1)-1)));
               log_data.items{log_data_cntr}.longitude=str2num(string((v(1)+1):(v(2)-1)));
               log_data.items{log_data_cntr}.altitude=str2num(string((v(2)+1):(v(3)-1)));
               log_data.items{log_data_cntr}.accuracy=str2num(string((v(3)+1):end));
           case 'U;' %% User log-data
               log_data_cntr=log_data_cntr+1;
               no_user_items=no_user_items+1;
               log_data.items{log_data_cntr}.sensor='U';
               log_data.items{log_data_cntr}.string=string(3:end);               
           otherwise
             keyboard
             error('Sensor type not defined');
       end;
       string=fgetl(fid); 
    end;
    log_data.no_sound_samples_in=no_sound_samples_in;
    log_data.no_accelerometer_items=no_acc_items;
    log_data.no_magnetic_items=no_mag_items;
    log_data.no_prox_items=no_prox_items;
    log_data.no_wifi_items=no_wifi_items;
    log_data.no_gps_items=no_gps_items;
    log_data.no_user_items=no_user_items;
    log_data.no_items_tot=log_data_cntr;

end
function string_out=chop_comma_and_on(string_in)
    if (string_in(1)==' ')
        string_in=string_in(2:end);
    end;
    t=min(findstr(string_in,','))-1;
    if isempty(t)
        t=length(string_in);
    end;
    string_out=string_in(1:t);
    t=strfind(string_out,']');
    if ~isempty(t)
       string_out=string_out(1:(min(t)-1));
    end;
end


