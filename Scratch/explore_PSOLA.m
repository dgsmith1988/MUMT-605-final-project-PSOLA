clear;
addpath(".\yin")
filename = 'flute2.wav';
[x, Fs] = audioread(filename);
T = 1/Fs;
results = yin(filename);

figure;
subplot(2, 1, 1);
plot((1:length(x))/Fs, x);
xlim([0 3.5])
title('Original x[n]');
subplot(2, 1, 2);
time_axis = (1:length(results.f0)) * results.hop * T;
% p(p==0) = NaN;
% plot(time_axis(p~=0), p(p~=0));
plot(time_axis, results.f0);
% plot(time_axis, f0);
title("YIN Output");
xlim([0 3.5]);

f0 = results.f0;
f0((isnan(f0))) = 0;
% DAFX_pitch_marks = findpitchmarks(x, Fs, f0, results.hop, results.wsize);
my_pitch_marks = getPitchMarks(x, Fs, f0, results.hop, results.wsize);

y_mine = psola(x, my_pitch_marks, .75, 1);
% y_DAFX = psola(x, DAFX_pitch_marks, 1, 1.25);
