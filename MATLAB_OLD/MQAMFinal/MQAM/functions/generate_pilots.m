function [data_sent_pilot, ts_pilot] = generate_pilots(data_sent,pilot_int,ts_pilot_length,Nb,pilot,levels)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
%Function that adds pilots to the middle of transmission.


if(pilot == 1) % if pilots are used, they must be inserted in the data.
    no_pilots = floor((Nb/(2*levels)/pilot_int)) %number of pilots in the middle of txmission
    if(no_pilots > 0)
        %use training sequence
        ts_pilot = [ones(1,2*levels) zeros(1,2*levels) randint((ts_pilot_length-2)*2*levels,1,2)'];
%         ts_pilot = ts(1:ts_pilot_length*2*levels); %generate pilots samples from training sequence.
        data_temp = data_sent';
        data_sent_pilot = [];
        for(k=1:no_pilots) %merge data with pilots
            aux = [data_temp((k-1)*pilot_int*2*levels+1:k*pilot_int*2*levels) ts_pilot];
            data_sent_pilot = [data_sent_pilot aux];
        end
        %fill with the rest of bits
        if(k*pilot_int*2*levels < length(data_temp))
            data_sent_pilot = [data_sent_pilot data_temp(k*pilot_int*2*levels+1:end)]; 
        end
    end
else %if pilots are not being used.
    data_sent_pilot = data_sent;
    ts_pilot =[];
end
data_sent_pilot = reshape(data_sent_pilot,length(data_sent_pilot),1);
end

