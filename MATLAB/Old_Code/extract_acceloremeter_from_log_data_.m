function accelerometer  = extract_acceloremeter_from_log_data( log_data )
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

accelerometer.x=zeros(log_data.no_accelerometer_items,1);
accelerometer.y=zeros(log_data.no_accelerometer_items,1);
accelerometer.z=zeros(log_data.no_accelerometer_items,1);

ix=0;
for item_i=1:length(log_data.items)
    if (log_data.items{item_i}.sensor=='A')
        ix=ix+1;
        accelerometer.x(ix)=log_data.items{item_i}.x;
        accelerometer.y(ix)=log_data.items{item_i}.y;
        accelerometer.z(ix)=log_data.items{item_i}.z;
    end;
end

