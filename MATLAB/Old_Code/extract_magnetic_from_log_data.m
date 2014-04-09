function magnetic  = extract_magnetic_from_log_data_( log_data )
%
% function sound_data_in = extract_sound_from_log_data(log_data)
%  
% Extract magnetometer readings from log_data structure.
% Copyright KTH Royal Institute of Technology, Per Zetterberg.

magnetic.x=zeros(log_data.no_magnetic_items,1);
magnetic.y=zeros(log_data.no_magnetic_items,1);
magnetic.z=zeros(log_data.no_magnetic_items,1);

ix=0;
for item_i=1:length(log_data.items)
    if (log_data.items{item_i}.sensor=='A')
        ix=ix+1;
        magnetic.x(ix)=log_data.items{item_i}.x;
        magnetic.y(ix)=log_data.items{item_i}.y;
        magnetic.z(ix)=log_data.items{item_i}.z;
    end;
end