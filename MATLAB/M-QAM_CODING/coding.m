clear
%% Coding
tic
Nb=15750; % Length of data
data = round(rand(1,Nb)); % Generate bits randomly
%     bin_fid=fopen('encoded.bin'); 
%     data=fscanf(bin_fid,'%1d'); %binary form
%     data=data';
%     fclose(bin_fid); %stop the pointers
%     Nb=length(data);

% Available Code rates: 1/2, 2/3, 3/4, 4/5
cr='3/4';    
enc_data=convencode(data,cr);
%enc_data=convEnco(data);
dec_data=convdecode(enc_data,cr);

toc;
errors = sum(dec_data(1:Nb)~=data);
%errors = sum(dec_data(1:Nb-4)~=data(1:Nb-4));
fprintf('Percentage of errors: %.2f %%\n',(errors/Nb)*100);