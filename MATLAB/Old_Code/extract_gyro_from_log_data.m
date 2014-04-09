function gyro  = extract_gyro_from_log_data( log_data )
%
% Extracts acceleromter data from log_data structure.
%
%
% Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
% This software is provided  ’as is’. It is free to use for non-commercial purposes.
% For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
% for a license. For non-commercial use, we appreciate citations of our work,
% please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
% for how information on how to cite.

gyro.x=zeros(log_data.no_gyro_items,1);
gyro.y=zeros(log_data.no_gyro_items,1);
gyro.z=zeros(log_data.no_gyro_items,1);

ix=0;
for item_i=1:length(log_data.items)
    if (log_data.items{item_i}.sensor=='A')
        ix=ix+1;
        gyro.x(ix)=log_data.items{item_i}.x;
        gyro.y(ix)=log_data.items{item_i}.y;
        gyro.z(ix)=log_data.items{item_i}.z;
    end;
end

