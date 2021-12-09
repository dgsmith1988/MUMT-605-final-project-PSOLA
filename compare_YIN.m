addpath('./yin');

[x, Fs] = audioread('Toms_diner.wav');
T = 1/Fs;
f0_min = 30;
H = 32; %analysis hop size
p_dafx = yinDAFX(x, Fs, f0_min, H);

% figure;
% subplot(2, 1, 1);
% plot((1:length(x))/Fs, x);
% title('Original x[n]');
% subplot(2, 1, 2);
% time_axis = (1:length(p)) * H * T;
% p(p==0) = NaN;
% plot(time_axis(p~=0), p(p~=0));
% plot(time_axis, p);
% title("YIN Output");

p_alain = yin('Toms_diner.wav');