clear;
addpath('.\Source');
addpath('.\Source\yin');
addpath('.\Sounds');

%Select the frequency so there the pitch period is an integer number of
%samples
f0 = 441;
Fs = 44100;
P0 = Fs/f0;
n = 0:3*Fs-1;
x = sin(2*pi*f0/Fs*n);
x = [zeros(1, 10*P0), x, zeros(1, 10*P0)]';

% input_file = 'flute2.wav';
% output_file = strcat('processed_', input_file);
% alpha = 1.5; %time-strech parameter
alpha = 1; %time-strech parameter
beta = nthroot(2, 12)^6; %pitch-shift parameter
% beta = 1; %pitch-shift parameter
% show_plots = true;
show_plots = false;

y = scale_pitch_and_time(x, Fs, alpha, beta, show_plots);

% disp('Press enter to hear the input.');
% pause();
disp('Playing the input...');
sound(.25*x, Fs);
disp('Press enter to hear the output.');
pause();
disp('Playing the output...');
sound(.25*y, Fs);

% audiowrite(output_file, y, Fs);