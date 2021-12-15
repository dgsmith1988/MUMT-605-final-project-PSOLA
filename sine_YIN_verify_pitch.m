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

alpha = 1; %time-strech parameter
% beta = nthroot(2, 12)^6; %pitch-shift parameter
% beta = 1.5; %pitch-shift parameter
beta = 1; %pitch-shift parameter
show_plots = false;

y = scale_pitch_and_time(x, Fs, alpha, beta, show_plots);

yin_x = yin(x, Fs);
yin_y = yin(y, Fs);

F0_ratio = yin_y.f0 ./ yin_x.f0;

figure;
subplot(2, 1, 1);
title('F0 estimates and ratio');
upper_lim = ceil(length(x)/Fs * 10 + 5) / 10;
time_axis = (1:length(yin_x.f0)) * yin_x.hop * (1/Fs);
plot(time_axis, yin_x.f0, 'DisplayName', 'x');
hold on;
plot(time_axis, yin_y.f0, 'DisplayName', 'y');
title("YIN Output");
xlabel('Time (sec)');
ylabel('F0 (Hz)');
xlim([0 upper_lim]);
legend();
hold off;

subplot(2, 1, 2);
plot(time_axis, F0_ratio, 'DisplayName', 'y/x F0 ratio');
title("Specified and Measured F0 Ratio");
yline(beta,'--k','DisplayName', 'Beta');
xlabel('Time (sec)');
ylabel('F0 Ratio');
legend();
xlim([0 upper_lim]);

figure;
f0_error = yin_y.f0 - beta*yin_x.f0;
ratio_error = F0_ratio - beta;
hold on;
plot(time_axis, ratio_error, 'DisplayName', 'Ratio');
ylabel('Ratio');
yyaxis right;
plot(time_axis, f0_error, 'DisplayName', 'F0');
ylabel('Hz');
title("Error");
hold off;
legend();
xlabel('Time (sec)');
xlim([0 upper_lim]);