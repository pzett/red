function [gb,gb_end,ts,data_sent,data_encoded,Nb] = generate_data(gb_length,gb_end_length,ts_length,Nb,levels,Nc,file,code,rate,iv)
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
    if(mod(length(data_sent)/(2*levels),Nc) ~= 0)
        fprintf('Added %g bits to fill OFDM symbol\n', 2*levels*(Nc-mod(length(data_sent)/(2*levels),Nc)));
        data_sent = [data_sent randint(2*levels*(Nc-mod(length(data_sent)/(2*levels),Nc)),1,2)'];
    end
    Nb = length(data_sent);
    if(code); data_encoded = LDPCenc(data_sent,rate); else; data_encoded = data_sent; end;
else
    %Number of bits to be transmitted
    data_sent = randint(Nb,1,2); % generate random data
    if(code==1); data_encoded = LDPCenc(data_sent,rate); else; data_encoded = data_sent; end;
end

ts = randint(ts_length*2*levels,1,2); % generate training sequence
gb = randint(gb_length*2*levels,1,2); % generate guard band
gb_end = randint(gb_end_length*2*levels,1,2); % generate guard band in end

if(iv)
    data_encoded = scramble(data_encoded);
end
data_sent = reshape(data_sent,length(data_sent),1);
data_encoded = reshape(data_encoded,length(data_encoded),1);
end

