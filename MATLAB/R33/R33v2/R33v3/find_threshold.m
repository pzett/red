function [ k_index ] = find_threshold( r )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
threshold=100; %define amplitude threshold to start  -> change accordingly.

% Loop to identify sample where received sequence is initialized
for(k=1:length(r))
    if(r(k)>threshold)
        k_index=k;
        break
    end
end

end

