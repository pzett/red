function [ phases refs ] = estimate_pilot_phases(pilots,ts,Nc)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

phases = zeros(Nc,size(pilots,2));
refs = zeros (Nc,size(pilots,2));
ts_matrix=reshape(ts,Nc,length(ts)/Nc);
for(k=1:size(pilots,2))
aux = reshape(pilots(:,k),Nc,length(pilots(:,k))/Nc);
for(q=1:Nc)
[phases(q,k) refs(q,k) qq qa] = phase_estimation(aux(q,:),ts_matrix(q,:));
end

end

