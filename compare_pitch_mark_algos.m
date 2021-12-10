clear;
dbstop if error;
addpath(".\yin")
filename = 'flute2.wav';
[x, Fs] = audioread(filename);
T = 1/Fs;
results = yin(filename);

F0 = results.f0;
F0((isnan(F0))) = 0;
P0 = zeros(1, length(F0));
hop = results.hop;
frame_length = results.wsize;

pitch_marks = getPitchMarks(x, Fs, F0, hop, frame_length);
DAFX_pitch_marks = findpitchmarks(x, Fs, F0, hop, frame_length);
DAFX_pitch_marks = DAFX_pitch_marks(DAFX_pitch_marks < length(x));

figure;
plot(x, 'DisplayName', 'Signal')
hold on;
plot(pitch_marks, x(pitch_marks), 'or', 'DisplayName', 'Mine');
plot(DAFX_pitch_marks, x(DAFX_pitch_marks), 'og', 'DisplayName', 'Theirs');
title("Signal w/ Pitch Marks");
legend();