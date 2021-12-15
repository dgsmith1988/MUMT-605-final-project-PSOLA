function y = scale_pitch_and_time(x, Fs, alpha, beta, show_plots)
%This function calls the constituent functions required to perform
%pitch/time scaling via the PSOLA algorithm. This is divided into three
%parts: F0 estimation, pitch mark determination, and the PSOLA itself.
addpath('.\Source\yin');


%The first step in the PSOLA alogorithm is to get estimates for the
%fundamental frequency so we can then determine the pitch periods. The YIN
%algorithm was chosen as the method to estimate F0.
yin_output = yin(x, Fs);

if show_plots
    figure;
    subplot(2, 1, 1);
    plot((1:length(x))/Fs, x);
    upper_lim = ceil(length(x)/Fs * 10 + 5) / 10;
    xlim([0 upper_lim])
    title('Original x[n]');
    subplot(2, 1, 2);
    time_axis = (1:length(yin_output.f0)) * yin_output.hop * (1/Fs);
    plot(time_axis, yin_output.f0);
    title("YIN Output");
    xlim([0 upper_lim]);
end

%Due to how the YIN algorithm implements things we need to set the NaN
%values to 0 for the unvoiced frames.
F0_est = yin_output.f0;
F0_est((isnan(F0_est))) = 0;

%Now that we have the fundamental frequency estimates we can determine the
%pitch marks
pitch_marks = get_pitch_marks(x, Fs, F0_est, yin_output.hop, yin_output.wsize, show_plots);
if show_plots
    %plot the pitch marks on top of the signal first so we can check things
    figure;
    plot(x, 'DisplayName', 'Signal');
    hold on;
    plot(pitch_marks, x(pitch_marks), 'ro', 'DisplayName', 'Pitch Marks');
    hold off;
    legend()
    title('Calculated Pitch Marks');
end

y = psola(x, alpha, beta, pitch_marks);
end