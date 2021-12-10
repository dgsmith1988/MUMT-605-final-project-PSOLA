clear;
addpath('.\Source');
addpath('.\Source\yin');
addpath('.\Sounds');

input_file = 'flute2.wav';
output_file = strcat('processed_', input_file);
alpha = 1; %time-strech parameter
beta = nthroot(2, 12); %pitch-shift parameter
% show_plots = true;
show_plots = false;

[x, Fs] = audioread(input_file);
y = scale_pitch_and_time(x, Fs, alpha, beta, show_plots);

% disp('Press enter to hear the input.');
% pause();
disp('Playing the input...');
sound(.5*x, Fs);
disp('Press enter to hear the output.');
pause();
disp('Playing the output...');
sound(.5*y, Fs);

% audiowrite(output_file, y, Fs);