% test_harness_A6.m
%
% This code is for Android Assignmet 6 test_harness.
%
% We want to test a function which takes a sequence of
% real numbers (doubles) and decode a secuence using Goertzel algorithm.
% Based on test_harness_example.m
%
% Copyright KTH Royal Institute of Technology, Martin Ohlsson, Per Zetterberg
% This software is provided  ’as is’. It is free to use for non-commercial purposes.
% For commercial purposes please contact Peter Händel (peter.handel@ee.kth.se)
% for a license. For non-commercial use, we appreciate citations of our work,
% please contact, Per Zetterberg (per.zetterberg@ee.kth.se), 
% for how information on how to cite. 

f1=441;
f2=4410;
n=100;
fs=44100;

if ~exist('been_here')
    fprintf(1,'Set do_test=true in test_harness(), press any key when ready \n');
    pause
    been_here=1;
end;

% This variable has to point to the correct apk file.
PathToAPKFile='"C:\Users\sergi_000\red\FrameWork06\bin\Framework06.apk"';
disp('Looking for Apk in the following directory:');
disp(PathToAPKFile);
% Generate random data input, and save on the file indata.txt
%no_of_real=ceil(10*rand)+2;
no_of_real=5000;
data_in=randn(1,no_of_real);
fid=fopen('indata.txt','wt');
fprintf(fid,'%d \n',no_of_real);
for i1=1:no_of_real
    fprintf(fid,'%f \n',data_in(i1));
end;
fclose(fid);

% Copy file to sdcard
copy_file_from_working_directory_to_sdcard('indata.txt');

pause(1);

% Install the APK
cmd_str=['C:\android\adt-bundle-windows-x86_64-20140321\sdk\platform-tools\adb install -r ',PathToAPKFile];
system(cmd_str);

pause(1);

% Run the framework
  %Make sure that the packae route and the app is well written
    % Package: se.kth.android.GroupRed2014
    % App: se.kth.android.FrameWork.FrameWork
cmd_str='C:\android\adt-bundle-windows-x86_64-20140321\sdk\platform-tools\adb shell am start -a android.intent.action.MAIN -n se.kth.android.GroupRed2014A6/se.kth.android.FrameWork.FrameWork';
system(cmd_str);

pause(3);

% Copy the results back to working directory
copy_file_from_sdcard_to_working_directory('outdata.txt');

% Read the results from the file
data_out_phone=load('outdata.txt');
%runs the function that shall be tested
%data_out_matlab=square(data_in);  

data_out_matlab=goertzelmod(f1,f2,fs,n,data_in);  

figure(1);
hold off
plot(data_out_matlab,'rx');
hold on
plot(data_out_phone,'o');
xlabel('Input values');
ylabel('Output values');
legend('Matlab result','Phone result');
title('Compare matlab and phone, should be identical');
grid
figure(1);

figure(2); subplot(1,2,1);
stem(data_out_matlab);
title('Matlab');
subplot(1,2,2);
stem(data_out_phone);
title('Phone');

