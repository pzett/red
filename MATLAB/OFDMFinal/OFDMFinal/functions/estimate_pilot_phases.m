function [ phases refs ] = estimate_pilot_phases(pilots,ts,Nc)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Estimate the channel using the pilots as if they were training sequences.


phases = zeros(Nc,size(pilots,2));
refs = zeros (Nc,size(pilots,2));
ts_matrix=reshape(ts,Nc,length(ts)/Nc);
for(k=1:size(pilots,2))
aux = reshape(pilots(:,k),Nc,length(pilots(:,k))/Nc);
for(q=1:Nc)
[phases(q,k) refs(q,k) qq qa] = phase_estimation(aux(q,:),ts_matrix(q,:));
end

end

