[x, Fs] = audioread('la.wav');
f0_min = 50; %minimum detectable pitch
H = 32; %hop size in samples, what does this impact...

%initialize the different parameters
yin_tolerance = 0.22;
lag_max = round(Fs/f0_min);
lags = 0:lag_max;
yin_length = 1024;
frame_length = yin_length + lag_max;
k = 0;

frame_start_index = 1:H:(length(x) - frame_length);
f0_est = zeros(1, length(frame_start_index));

%frame processing loop
for i = frame_start_index
    k = k + 1;
    frame_data = x(i:i+(yin_length + lag_max));
    
    %take the signal segment and calculate the sum of the squared differences
    diff_squared = ones(1, lag_max);
    for lag = lags
        i1 = 1 + lag;
        i2 = i1 + yin_length;    
        diff_squared(lags == lag) = sum((frame_data - frame_data(i1:i2)).^2);
    end
    
    %now lets calculate the normalized difference function
    NMDF = zeros(1, length(lags));
    NMDF(lags == 0) = 1;
    lag_1_index = find(lags == 1);
    for lag = lags(lags > 0)
        i2 = find(lags == lag);
        NMDF(i2) = diff_squared(i2) / (sum(diff_squared(lag_1_index:i2)) / lag) ;
    end
end