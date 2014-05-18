function copy_file_from_working_directory_to_sdcard( filename )
%
% function copy_file_from_sdcard_to_working_directory( filename )
%
% The name of this file should explain what it does.
%
%
% Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
% This software is provided  �as is�. It is free to use for non-commercial purposes.
% For commercial purposes please contact Peter H�ndel (peter.handel@ee.kth.se)
% for a license. For non-commercial use, we appreciate citations of our work,
% please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
% for how information on how to cite.


   cmd_str=['adb push ',filename,' /sdcard/',filename];
   system(cmd_str);
end