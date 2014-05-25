function [ phases, refs ] = estimate_pilot_phases(pilots,ts)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Estimate the channel using the pilots as if they were training sequences.


phases = zeros(1,size(pilots,2));
refs = zeros (1,size(pilots,2));

for(k=1:size(pilots,2))
aux = pilots(:,k);
[phases(k) refs(k) qq qa] = phase_estimation(aux,ts);
end

end

