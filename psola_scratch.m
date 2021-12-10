clear;
addpath(".\yin")
filename = 'flute2.wav';
[x, Fs] = audioread(filename);
T = 1/Fs;
results = yin(filename);

% figure;
% subplot(2, 1, 1);
% plot((1:length(x))/Fs, x);
% xlim([0 3.5])
% title('Original x[n]');
% subplot(2, 1, 2);
% time_axis = (1:length(results.f0)) * results.hop * T;
% plot(time_axis, results.f0);
% title("YIN Output");
% xlim([0 3.5]);

f0 = results.f0;
f0((isnan(f0))) = 0;
% DAFX_pitch_marks = findpitchmarks(x, Fs, f0, results.hop, results.wsize);
my_pitch_marks = getPitchMarks(x, Fs, f0, results.hop, results.wsize);

%set all the unvoiced frames to have a fundamental frequency for easier
%processing later
first_non_zero = find(f0, 1);
zero = find(~f0);
change_index = find(diff(zero) > 1);
f0(1:change_index) = f0(first_non_zero);
ending_index = zero(change_index+1);
f0(ending_index:end) = f0(ending_index-1);
P0 = round(Fs./f0);

alpha = 1; %time-stretch parameter
beta = 1.25; %pitch-shift parameter

%find the first frame where the current pitch mark exists, this can be
%redone in a more elegant fashion later, skip the end points for now to
%make things easier and not deal with the corner cases
output = zeros(1, round(alpha*length(x)));
output_pitch_mark = P0(1) + 1; %add one here to make it so 

truncated_PM = my_pitch_marks(2:end-1);

while output_pitch_mark < length(output)
    [~, i] = min( abs(alpha*truncated_PM - output_pitch_mark) );
    local_P0 = P0(i);
    L = 2*local_P0 + 1;
    i_upper = truncated_PM(i) + local_P0;
    i_lower = truncated_PM(i) - local_P0;
    windowed_segment = hanning(L, 'symmetric')' .* x(i_lower:i_upper)';
    
    out_start = output_pitch_mark - local_P0;
    out_end = output_pitch_mark + local_P0;
    
    if out_end > length(output)
        break
    end
    
    %perform the overlap and add aspect of the algorithm
    output(out_start:out_end) = output(out_start:out_end) + windowed_segment;
    output_pitch_mark = round(output_pitch_mark + local_P0/beta);
end