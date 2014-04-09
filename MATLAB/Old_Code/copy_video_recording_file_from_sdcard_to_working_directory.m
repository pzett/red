
function copy_video_recording_file_from_sdcard_to_working_directory( filename )
%
% function copy_video_recording_file_from_sdcard_to_working_directory( filename )
%
% The function copies the named file from the recordings directory on the
% SDRAM card to the working directory. No path names shall be used.
%
% Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
% This software is provided  ’as is’. It is free to use for non-commercial purposes.
% For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
% for a license. For non-commercial use, we appreciate citations of our work,
% please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
% for how information on how to cite.

   cmd_str=['adb pull sdcard/recordings/',filename,' ',filename];
   system(cmd_str);
end