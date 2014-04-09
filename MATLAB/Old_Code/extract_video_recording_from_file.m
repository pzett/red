function rgb_video = extract_video_recording_from_file( filename )
%
% function rgb_video = extract_video_recording_from_file( filename )
%
% This function extracts the video frames from a video file recored with
% FrameWork (either using the camera GUI or using the save_rgb_frame_on_file
% function). The field rgb_video.number_of_frames gives you the number
% of frame (i.e. images). The i:th frame data is contained in rgb_video.frames{i}.
% The cell has the fields "width", "height", "rgb_raw" and "rgb". The first two
% parameters gives you the dimention of the bitmap. The third parameter
% i.e. "rgb_raw", gives you the exact byte-by-byte represenation of the
% "byte[]" object in FrameWork. The last parameter "rgb", gives a
% representation such that the command "image(rgb_video.frames{i}.rgb)" can
% be used to plot the image from Matlab. The RGB intensities in matlab
% are in the range 0-1 in Matlab while they are 0-255 in Framework.
% This function compensates for this difference.

    fid=fopen(filename,'r');
    fc=0;

    width_msB=fread(fid,1,'uint8');
    number_of_frames=0;
    
    while ~feof(fid)
        fc=fc+1;
            
        
        width_lsB=fread(fid,1,'uint8');
        width=width_msB*256+width_lsB;
    
        height_msB=fread(fid,1,'uint8');
        height_lsB=fread(fid,1,'uint8');
        height=height_msB*256+height_lsB;
        
        ix_C0=zeros(width*height,1);
        for i1=1:height
            for i2=1:width
                ix_C0((i1-1)*width+i2)=(height-i1)*width+i2;
            end;
        end;

    
        rgb_raw=fread(fid,3*width*height,'uint8');
        C=zeros(width,height,3);
        ix_raw=1:3:(3*width*height);
        ix_C=ix_C0;
        C(ix_C)=rgb_raw(ix_raw)/255;
        
        ix_raw=2:3:(3*width*height);
        ix_C=ix_C0+width*height;
        C(ix_C)=rgb_raw(ix_raw)/255;
        
        ix_raw=3:3:(3*width*height);
        
        ix_C=ix_C0+2*width*height;
        C(ix_C)=rgb_raw(ix_raw)/255;
        
        
        rgb_video.frames{fc}.raw=rgb_raw;
        rgb_video.frames{fc}.rgb=C;
        rgb_video.frames{fc}.width=width;
        rgb_video.frames{fc}.height=height;
        
        width_msB=fread(fid,1,'uint8');
        number_of_frames=number_of_frames+1;
    end;
    fclose(fid);
    rgb_video.number_of_frames=number_of_frames;
end

