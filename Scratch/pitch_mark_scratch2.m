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

guess_window = 20; %determine theoretical aspects regarding the bounds on this and the F0 estimate

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
% figure;
% plot(x(frame_start:frame_end));
% hold on;
% plot(pitch_marks, x(pitch_marks), "or");
% title(sprintf("Frame #%i", i))

%go in and clean up the different pitch mark guess so things are
%aligned more correctly...
corrected_pm = zeros(1, length(pitch_marks));
for k = length(pitch_marks):-1:1
    search_range = pitch_marks(k)-guess_window:pitch_marks(k)+guess_window;
    [~, k2] = max(x(search_range));
    corrected_pm(k) = search_range(k2);
%     xline([search_range(1), search_range(end)], '--')
end
% plot(corrected_pm, x(corrected_pm), "*g");
% hold off;

%subtract one to make sure the last pitch mark found can be found in the
%new analysis frame
frame_jump = floor(frame_length/hop) - 1;

while i + frame_jump < length(F0)
    if F0(i + frame_jump) == 0
        F0(i + frame_jump) = F0(i);
    end
    i = i + frame_jump;
    frame_start = 1 + (i-1)*hop;
    frame_end = frame_start + frame_length - 1;
    
    if frame_end > length(x)
        frame_end = length(x);
    end
    
    P0 = round(Fs/F0(i));
    
    new_pm = pitch_marks(end) + P0;
    while new_pm(end) + P0 < frame_end
        new_pm = [new_pm, new_pm(end) + P0];
    end
%     
%     figure;
%     plot(frame_start:frame_end, x(frame_start:frame_end));
%     hold on;
%     plot(new_pm, x(new_pm), "or");
%     plot(pitch_marks(end), x(pitch_marks(end)), "om");
%     title(sprintf("Frame #%i", i))
    
    corrected_pm = zeros(1, length(new_pm));
    for k = length(new_pm):-1:1
        upperLim = new_pm(k)+guess_window;
        if upperLim > length(x)
            upperLim = length(x);
        end
        search_range = new_pm(k)-guess_window:upperLim;
        [~, k2] = max(x(search_range));
        corrected_pm(k) = search_range(k2);
%         xline([search_range(1), search_range(end)], '--')
    end
%     plot(corrected_pm, x(corrected_pm), "*g");
%     hold off;
    
    %copy the data into the larger pitch_mark tracking data structure
    pitch_marks = [pitch_marks, corrected_pm];
end


