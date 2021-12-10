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
plot(time_axis, results.f0);
title("YIN Output");
xlim([0 3.5]);

f0 = results.f0;
f0((isnan(f0))) = 0;
% DAFX_pitch_marks = findpitchmarks(x, Fs, f0, results.hop, results.wsize);
my_pitch_marks = getPitchMarks(x, Fs, f0, results.hop, results.wsize);

%set all the unvoiced frames to have a pitch period for easier processing
%later
first_non_zero = find(f0, 1);
zero = find(~f0);
change_index = find(diff(zero) > 1);
f0(1:change_index) = f0(first_non_zero);
ending_index = zero(change_index+1);
f0(ending_index:end) = f0(ending_index-1);


%plot the pitch marks on top of the signal first so we can check to make
%sure that all the windows are aligned properly later
figure;
plot(x/abs(max(x)));
hold on;
plot(my_pitch_marks, x(my_pitch_marks)/abs(max(x)), 'ro');
grid on;
grid minor;
hold off;

%find the first frame where the current pitch mark exists, this can be
%redone in a more elegant fashion later, skip the end points for now to
%make things easier and not deal with the corner cases
figure;
for j = 2:length(my_pitch_marks) - 1
    pm = my_pitch_marks(j);
    for i = 1:length(f0)
        lower_bound = 1 + (i-1)*results.hop;
        upper_bound = lower_bound + results.wsize - 1;
        if pm <= upper_bound && pm >= lower_bound
            P0 = round(Fs/f0(i));
            break
        end
    end
    L = 2*P0 + 1;
    window = hanning(L, 'symmetric');
    upper = pm + floor(L/2);
    lower = pm - floor(L/2);
    extract = x(lower:upper) .* window;
    if mod(j, 100) == 0
%         plot(lower:upper, window, '--k');
        plot(lower:upper, extract);
        hold on;
    end
end
hold off;