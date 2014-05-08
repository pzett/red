function create_file_of_shorts( filename, data )

if (max(abs(data(:)))>2^15-1)
    error('The data need to be in the range [-2^15,2^15-1]');
end;
if (max(abs(data(:)))<2)
    fprintf(1,['I think your data has to small amplitude \n',...
        'note that the data should be in the range [-2^15,2^15-1] \n']);
    pause(1);
    fprintf(1,'Press any key to continue \n');
    pause
end;

if (size(data,2)>size(data,1))
    data=data';
end;

temp=zeros(1,size(data,1)*size(data,2));
for i1=1:size(data,2)
    ix=(i1-size(data,2))+size(data,2)*(1:size(data,1));
    temp(ix)=data(:,i1);    
end


fid=fopen(filename,'w');
fwrite(fid,temp,'int16');
fclose(fid);


