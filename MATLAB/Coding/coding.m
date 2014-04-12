clear
%% Coding
tic
Nb=10000; % Length of data
data = round(rand(1,Nb)); % Generate bits randomly
%     bin_fid=fopen('encoded.bin'); 
%     data=fscanf(bin_fid,'%1d'); %binary form
%     data=data';
%     fclose(bin_fid); %stop the pointers
%     Nb=length(data);

% Available Code rates: 1/2, 2/3, 3/4, 4/5
 % Specify the random stream to obtain repeatable results
s = RandStream('mt19937ar', 'Seed', 12345);
p=linspace(1e-10,1e-2,20);
BER=zeros(5,length(p));
cr={'0','1/2','2/3','3/4','4/5'};
for j=1:5
   for i=1:length(p)
   enc_data=convencode(data,char(cr(j)));
   [rcvd_data,error_vec]=bsc(enc_data,p(i),s);
   dec_data=convdecode(rcvd_data,char(cr(j)));
   errors = sum(dec_data(1:Nb)~=data);
   BER(j,:)=(errors/Nb)*100;
   reset(s);
   end
end
yax=1:20;
plot(BER(1,:),yax,BER(2,:),yax,BER(3,:),yax,BER(4,:),yax,BER(5,:));

    toc;
%errors = sum(dec_data(1:Nb-4)~=data(1:Nb-4));
fprintf('Percentage of errors: %.2f %%\n',(errors/Nb)*100);
