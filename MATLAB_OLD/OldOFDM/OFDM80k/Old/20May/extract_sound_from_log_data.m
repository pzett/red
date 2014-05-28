function sound_data_in = extract_sound_from_log_data(log_data)
%
%
% function sound_data_in = extract_sound_from_log_data(log_data)
%
% Extracts sound from log_data structure.
% Copyright KTH Royal Institute of Technology, Per Zetterberg.


sound_data_in=zeros(log_data.no_sound_samples_in,1);
sound_sample_index=0;

for item_i=1:length(log_data.items)
    if (log_data.items{item_i}.sensor=='S')
        N=length(log_data.items{item_i}.buffer);
        ix=sound_sample_index+(1:N);
        sound_data_in(ix)=log_data.items{item_i}.buffer;
        sound_sample_index=sound_sample_index+N;
    end;
end;