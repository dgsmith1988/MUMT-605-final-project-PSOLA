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

alpha = 1.5; %time-strech parameter
beta = 1; %pitch-shift parameter
% show_plots = false;
show_plots = true;

y = scale_pitch_and_time(x, Fs, alpha, beta, show_plots);

figure;
subplot(2, 1, 1);
plot(x)
xlabel("Samples");
ylabel("Amplitude");
subplot(2, 1, 2);
plot(y);
xlabel("Samples");
ylabel("Amplitude");