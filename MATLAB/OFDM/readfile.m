function bin = readfile(filename)
% Converts the ascii characters given in a TEXT file to a binary string of data.
%Usage- bin = readfile(filename)
%Iputs-
%    filename- name the file (Eg- 'try.txt')
%    constellation- constellation size
%    no_symb- symbols per packet
%Outputs
%    bin- the binary string of data

fdr = fopen(filename,'r'); % Open the file to read 
if (fdr == -1)
    disp('File cannot be opened or found');
else
    input = fread(fdr);
end

fclose(fdr);
bin = num2binmap(input); % Convert the ascii characters(numbers) into binary



end

