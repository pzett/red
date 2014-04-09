function create_video( filename, rgb_video )
%
% 
%
% The function creates a video according to the file format described in
% the slideset documentation of this code.
% The input, rgb_video, is identical to the output of 
% extract_video_recording_from_file, except the "rgb_raw" field is not used
% and does not need to exist. This function can be used to create an image
% and subsequently upload it to the phone using 
% copy_file_from_working_directory_to_recordings( filename ).
%
% Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
% This software is provided  ’as is’. It is free to use for non-commercial purposes.
% For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
% for a license. For non-commercial use, we appreciate citations of our work,
% please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
% for how information on how to cite.

    fid=fopen(filename,'w');
    
    for fc=1:length(rgb_video.frames)
        
        width=rgb_video.frames{fc}.width;        
        height=rgb_video.frames{fc}.height;
    
        fwrite(fid,floor(width/256),'uint8');
        fwrite(fid,width-floor(width/256)*256,'uint8');
        fwrite(fid,floor(height/256),'uint8');
        fwrite(fid,height-floor(height/256)*256,'uint8');
        
        rgb_raw=zeros(3*width*height,1);
        
        ix_C0=zeros(width*height,1);
        for i1=1:height
            for i2=1:width
                ix_C0((i1-1)*width+i2)=(height-i1)*width+i2;
            end;
        end;
        
        C=rgb_video.frames{fc}.rgb;
        
        for i1=0:2
        
            ix_C=ix_C0+i1*width*height;
            ix_raw=(1:3:(3*width*height))+i1;
        
            temp=255*C(ix_C);
            if (sum(abs(temp(:)-round(temp(:))))>0) 
                error('The rgb intensities have to be integers/255');
            end;
            if (max(temp(:))>255)            
                error('The maximum rgb intensity is 1');
            end;
            if (min(temp(:))<0)            
                error('The minimum rgb intensity is 1');
            end;        
            rgb_raw(ix_raw)=255*C(ix_C);
        
        end;
        fwrite(fid,rgb_raw,'uint8');
    end;
    fclose(fid);

   