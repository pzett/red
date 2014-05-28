function [gb,gb_end,ts,data_sent,Nb] = generate_data(gb_length,ts_length,Nb,levels,file,iv)
%Author : Red Group - Francisco Rosario (frosario@kth.se)

if(file) %pick a file from the computer and convert to bits
    [filename,pathname,filterindex] = uigetfile('*.*','Pick a file');
    if(filterindex==0); error('You must choose a file !'); end;
    str =[pathname,filename];
    data_sent = bytestobits(str);
    [vec_name,vec_size] = bytestobitsnew(str,filename);
    data_sent = [vec_name vec_size data_sent]; %merge encoded name and size with data.
    if(mod(length(data_sent),2*levels) ~= 0 )
        data_sent = [data_sent  zeros(1,2*levels-mod(length(data_sent),2*levels))];
        fprintf('Added %g bits to fill constellation symbol\n', 2*levels-mod(length(data_sent),2*levels));
    end
    fprintf('The file has %g bytes\n',length(data_sent)/8);
    Nb = length(data_sent);
    
else
    %Number of bits to be transmitted
    data_sent = randint(Nb,1,2); % generate random data
    
end

ts = randint(ts_length*2*levels,1,2); % generate training sequence
gb = randint(gb_length*2*levels,1,2); % generate guard band
gb_end = randint(gb_length*2*levels,1,2); % generate guard band in end

if(iv)
    data_sent = scramble(data_sent);
end
data_sent = reshape(data_sent,length(data_sent),1);
if(mod(length(data_sent),2*levels) ~= 0 )
    fprintf('Added %g bits to fill constellation symbol\n', 2*levels-mod(length(data_sent),2*levels));
    data_sent = [data_sent ; zeros(2*levels-mod(length(data_sent),2*levels),1)];
    
end

end

