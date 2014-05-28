function [  ] = create_dictionaries()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

text_file = './dict/text.txt';
audio_file = './dict/audio.wav';
image_file = './dict/image.png';

fid = fopen(text_file,'r');
file_data = fread(fid);
binranges = 0:255;
bincounts = histc(file_data,binranges);
stem(binranges,bincounts);

[dict,avglen] = huffmandict(binranges,bincounts/length(file_data));
save('./dict/text_dict.mat','dict','avglen');

fid = fopen(audio_file,'r');
file_data = fread(fid);
binranges = 0:255;
bincounts = histc(file_data,binranges);
stem(binranges,bincounts);

[dict,avglen] = huffmandict(binranges,bincounts/length(file_data));
save('./dict/audio_dict.mat','dict','avglen');


fid = fopen(image_file,'r')
file_data = fread(fid);
binranges = 0:255;
bincounts = histc(file_data,binranges);
stem(binranges,bincounts);

[dict,avglen] = huffmandict(binranges,bincounts/length(file_data));
save('./dict/image_dict.mat','dict','avglen');


end

