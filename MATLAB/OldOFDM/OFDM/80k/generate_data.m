function [gb,ts,data_sent,data_encoded,Nb] = generate_data(gb_length,ts_length,Nb,levels,Nc,file,code,rate)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if(file)
    [filename,pathname,filterindex] = uigetfile('*.*','Pick a file');
    if(filterindex==0); error('You must choose a file !'); end;
    str =[pathname,filename];
    data_sent = bytestobits(str);
    [vec_name,vec_size] = bytestobitsnew(str,filename);
    data_sent = [vec_size vec_name data_sent];
    if(code); else; data_encoded =[]; end;
    if(mod(length(data_sent),Nc) ~= 0 )
        data_sent = [data_sent  zeros(1,Nc-mod(length(data_sent),Nc))]';
        fprintf('The file has %g bytes\n',length(data_sent)/8);
    end
    Nb = length(data_sent);
else
    %Number of bits to be transmitted
    data_sent = randint(Nb,1,2); % generate random data
    if(code==1); data_encoded = LDPCenc(data_sent,rate); else; data_encoded = []; end;
end

ts = randint(ts_length*2*levels,1,2); % generate training sequence
gb = randint(gb_length*2*levels,1,2); % generate guard band

end

