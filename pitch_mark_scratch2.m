clear;
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

guess_window = 10; %determine theoretical aspects regarding the bounds on this and the F0 estimate

j = 1; %current pitch mark index
% pitch_marks = zeros(1, round(length(F0)/2));
% pitch_marks(j) = 1;

non_zero = find(F0);

if hop*non_zero(1) < frame_length
    disp("The pitch starts before the first full frame...");
    pitch_in_first_frame = true;
end

i = 1;
% handle the first frame differently
frame_start = 1 + (i-1)*hop;
frame_end = frame_start + frame_length - 1;

%given we know the signal is pitched within the first frame, start
%by finding the max value in order to make sure the pitch marks are
%aligned

[~, pitch_marks] = max(x(frame_start:frame_end));
P0(i) = round(Fs/F0(non_zero(1)));

while pitch_marks(end) + P0(i) < frame_end
    pitch_marks = [pitch_marks, pitch_marks(end) + P0(i)];
end
while pitch_marks(1) - P0(i) > frame_start
    pitch_marks = [pitch_marks(1) - P0(i), pitch_marks];
end
figure(1);
plot(x(frame_start:frame_end));
hold on;
plot(pitch_marks, x(pitch_marks), "or");
%             hold off;
title(sprintf("Frame #%i", i))
true;

%go in and clean up the different pitch mark guess so things are
%aligned more correctly...
corrected_pm = zeros(1, length(pitch_marks));
for k = length(pitch_marks):-1:1
    search_range = pitch_marks(k)-guess_window:pitch_marks(k)+guess_window;
    [~, k2] = max(x(search_range));
    corrected_pm(k) = search_range(k2);
    xline([search_range(1), search_range(end)], '--')
end
plot(corrected_pm, x(corrected_pm), "*g");
hold off;

frame_jump = floor(frame_length/hop);

i = 1;
i = i + frame_jump-1;
frame_start = 1 + (i-1)*hop;
frame_end = frame_start + frame_length - 1;
P0(i) = round(Fs/F0(i));
new_pm = pitch_marks(end) + P0(i);
while new_pm(end) + P0(i) < frame_end
    new_pm = [new_pm, new_pm(end) + P0(i)];
end

figure(2);
plot(frame_start:frame_end, x(frame_start:frame_end));
hold on;
plot(new_pm, x(new_pm), "or");
plot(pitch_marks(end), x(pitch_marks(end)), "om");
%             hold off;
title(sprintf("Frame #%i", i))