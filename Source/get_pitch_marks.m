function pitch_marks = get_pitch_marks(x, Fs, F0, hop, frame_length, show_plots)
non_zero = find(F0);

i = 1;
%handle the first frame differently as we have no preceeding data to refer
%to
frame_start = 1 + (i-1)*hop;
frame_end = frame_start + frame_length - 1;

%given we know the signal is pitched within the first frame, start
%by finding the max value in order to make sure the pitch marks are
%aligned
[~, pitch_marks] = max(x(frame_start:frame_end));
P0 = round(Fs/F0(non_zero(1)));
guess_window = ceil(P0/4);

while pitch_marks(end) + P0 < frame_end
    pitch_marks = [pitch_marks, pitch_marks(end) + P0(i)];
end
while pitch_marks(1) - P0 > frame_start
    pitch_marks = [pitch_marks(1) - P0, pitch_marks];
end

if show_plots
    figure;
    plot(x(frame_start:frame_end));
    hold on;
    h1 =  plot(pitch_marks, x(pitch_marks), "or", "DisplayName", "First Guess");
    title(sprintf("Frame #%i", i))
    xlabel("Samples");
    ylabel("Amplitude");
end

%go in and clean up the different pitch mark guess so things are
%aligned more correctly...
corrected_pm = zeros(1, length(pitch_marks));
for k = length(pitch_marks):-1:1
    upper_lim = pitch_marks(k) + guess_window;
    lower_lim = pitch_marks(k) - guess_window;
    if lower_lim < 1
        lower_lim = 1;
    end
    search_range = lower_lim:upper_lim;
    %     search_range = pitch_marks(k)-guess_window:pitch_marks(k)+guess_window;
    [~, k2] = max(x(search_range));
    corrected_pm(k) = search_range(k2);
    if show_plots
        xline([search_range(1), search_range(end)], '--')
    end
end

if show_plots
    h2 = plot(corrected_pm, x(corrected_pm), "*g", "DisplayName", "Corrected");
    legend([h1, h2], 'location', 'southwest');
    hold off;
end

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
    
    if show_plots
        figure;
        plot(frame_start:frame_end, x(frame_start:frame_end));
        hold on;
        h1 = plot(new_pm, x(new_pm), "or", "DisplayName", "First Guess");
        h2 = plot(pitch_marks(end), x(pitch_marks(end)), "om", "DisplayName", "Previous Frame");
        title(sprintf("Frame #%i", i))
    end
    
    corrected_pm = zeros(1, length(new_pm));
    guess_window = ceil(P0/4);
    for k = length(new_pm):-1:1
        upper_lim = new_pm(k) + guess_window;
        lower_lim = new_pm(k) - guess_window;
        if upper_lim > length(x)
            upper_lim = length(x);
        end
        if lower_lim < 1
            lower_lim = 1;
        end
        search_range = lower_lim:upper_lim;
        [~, k2] = max(x(search_range));
        corrected_pm(k) = search_range(k2);
        
        if show_plots
            xline([search_range(1), search_range(end)], '--k')
        end
    end
    
    if show_plots
        h3 = plot(corrected_pm, x(corrected_pm), "*g", "DisplayName", "Corrected");
        hold off;
        disp("Press enter to get the next plot.");
        legend([h1, h2, h3], 'location', 'southwest');
        xlabel("Samples");
        ylabel("Amplitude");
        pause;
    end
    
    %copy the data into the larger pitch_mark tracking data structure
    pitch_marks = [pitch_marks, corrected_pm];
end
end