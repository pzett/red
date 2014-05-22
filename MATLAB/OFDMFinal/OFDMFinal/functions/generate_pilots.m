function [data_sent_pilot, ts_pilot] = generate_pilots(data_sent,pilot_int,ts_pilot_length,Nb,pilot,levels)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
%Function that adds pilots to the middle of transmission.

if(mod(ts_pilot_length,2*levels) ~= 0 ); disp('Choose a pilot length multiple of 2*levels'); pause; end

if(pilot == 1) % if pilots are used, they must be inserted in the data.
    no_pilots = floor(Nb/pilot_int) %number of pilots in the middle of txmission
    if(no_pilots > 0)
        %use training sequence
        ts_pilot = ts(1:ts_pilot_length*2*levels); %generate pilots samples from training sequence.
        data_temp = data_sent;
        data_sent_pilot = [];
        for(k=1:no_pilots) %merge data with pilots
            aux = [data_temp((k-1)*pilot_int+1:k*pilot_int); ts_pilot];
            data_sent_pilot = [data_sent_pilot; aux];
        end
        %fill with the rest of bits
        if(k*pilot_int < length(data_temp))
            data_sent_pilot = [data_sent_pilot; data_temp(k*pilot_int+1:end)]; end
    end
else %if pilots are not being used.
    data_sent_pilot = data_sent;
    ts_pilot =[];
end

end

