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

guess_window = 5;

j = 1; %current pitch mark index
pitch_marks = zeros(1, round(length(F0)/2));
pitch_marks(j) = 1;

non_zero = find(F0);

if hop*non_zero(1) < frame_length
    disp("The pitch starts before the first full frame...");
end

for i = 1:length(F0)
    frame_start = 1 + (i-1)*hop;
    frame_end = frame_start + frame_length;
%     subplot(3, 1, mod(i, 3) + 1);
%     plot(x(frame_start:frame_end));
%     title(sprintf("Frame #%i", i))
    
    %lets start the analysis aspect
    if F0(i) == 0
        if i == 1
            %if the first frame is unvoiced then find the first voiced frame to
            %anticipate that as being the fundamental frequency
            P0(i) = round(Fs/F0(non_zero(1)));
        else
            %set the unvoiced frame to the the pitch period of the previous
            %frame
            P0(i)= P0(i-1);
        end
    else
        P0(i) = round(Fs/F0(i));
    end
    
    while(pitch_marks(j) + P0(i) < frame_end)
        guess = pitch_marks(j) + P0(i);
        [~, pitch_marks(j+1)] = max(guess-guess_window:guess+guess_window);
        j = j + 1;
    end
    
    plot(x(frame_start:frame_end));
    hold on;
    plot(pitch_marks(1:j), x(pitch_marks(1:j)), "or");
    hold off;
    title(sprintf("Frame #%i", i))
    true;
end
