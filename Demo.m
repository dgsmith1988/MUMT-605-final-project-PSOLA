clear;
dbstop if error;
addpath('.\Source');
addpath('.\Source\yin');
addpath('.\Sounds');

input_file = 'Toms_diner.wav';
% input_file = 'flute2.wav';
output_file = strcat('processed_', input_file);
alpha = 1/1.5; %time-strech parameter
beta = 1; %nthroot(2, 12); %pitch-shift parameter
% beta1 = nthroot(2, 12)^6; %pitch-shift parameter
% beta2 = nthroot(2, 12)^3; %pitch-shift parameter
% show_plots = true;
show_plots = false;

[x, Fs] = audioread(input_file);
y = scale_pitch_and_time(x, Fs, alpha, beta, show_plots);
% y = scale_pitch_and_time(x, Fs, alpha, beta1, show_plots);
% y2 = scale_pitch_and_time(x, Fs, alpha, beta2, show_plots);

% disp('Press enter to hear the input.');
% pause();
disp('Playing the input...');
sound(.5*x, Fs);
disp('Press enter to hear the output.');
pause();
disp('Playing the output...');
sound(.5*y, Fs);

audiowrite(output_file, y, Fs);