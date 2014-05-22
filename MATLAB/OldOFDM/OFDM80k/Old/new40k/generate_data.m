function [gb,gb_end,ts,data_sent,data_encoded,Nb] = generate_data(gb_length,gb_end_length,ts_length,Nb,levels,Nc,file,code,rate,iv)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if(file)
    [filename,pathname,filterindex] = uigetfile('*.*','Pick a file');
    if(filterindex==0); error('You must choose a file !'); end;
    str =[pathname,filename];
    data_sent = bytestobits(str);
    [vec_name,vec_size] = bytestobitsnew(str,filename);
%[vec_name,vec_size,data_sent] = read_file(str,filename);
    data_sent = [vec_name vec_size  data_sent];
    if(code); else; data_encoded =[]; end;
    if(mod(length(data_sent),2*levels) ~= 0 )
        data_sent = [data_sent  zeros(1,2*levels-mod(length(data_sent),2*levels))];     
    end
    fprintf('The file has %g bytes\n',length(data_sent)/8);
    if(mod(length(data_sent)/(2*levels),Nc) ~= 0)
        fprintf('Added %g bits to fill OFDM symbol\n', 2*levels*(Nc-mod(length(data_sent)/(2*levels),Nc)));
        data_sent = [data_sent randint(2*levels*(Nc-mod(length(data_sent)/(2*levels),Nc)),1,2)'];
    end
    
    Nb = length(data_sent);
else
    %Number of bits to be transmitted
    data_sent = randint(Nb,1,2); % generate random data
    if(code==1); data_encoded = LDPCenc(data_sent,rate); else; data_encoded = []; end;
end

ts = randint(ts_length*2*levels,1,2); % generate training sequence
gb = randint(gb_length*2*levels,1,2); % generate guard band
gb_end = randint(gb_end_length*2*levels,1,2); % generate guard band in end
data_sent = reshape(data_sent,length(data_sent),1); 
if(iv)
    st2 = 4831;
    data_sent = randintrlv(data_sent,st2);
end

%data_sent=interleaving(interleaving(data_sent,9,11),9,11);
end

