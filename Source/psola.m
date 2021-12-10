function y = psola(x, alpha, beta, pitch_marks)
%x = input signal
%alpha = time-scaling parameter
%beta = pitch-scaling parameter
%pitch_marks = pitch marks
%y = time/pitch scaled output signal

%calculate the pitch periods which are implicitly defined by the pitch
%marks. this method is perferable as the unvoiced segments have been
%properly labeled in this data from the preceding functions.
P0 = diff(pitch_marks);

%remove the first mark if it might casue a processing problem
if pitch_marks(1) <= P0(1)
    pitch_marks = pitch_marks(2:end);
    P0 = P0(2:end);
end
%remove the last pitch mark if it might extend beyond the length and cause
%a processing problem
if pitch_marks(end) + P0(end) > length(x)
    pitch_marks = pitch_marks(1:end-1);
else
    P0 = [P0, P0(end)];
end

%prepare the output buffer
y = zeros(round(alpha*length(x)), 1);

%determine the first synthesis pitch mark. adding the 1 is necessary here
%to ensure indexing by zero doesn't occur later when extracting the
%windowed segment.
output_pitch_mark = P0(1) + 1;

%now that everything is initialized we can start the main processing loop
while output_pitch_mark < length(y)
    [~, i] = min(abs(alpha*pitch_marks - output_pitch_mark));
    local_P0 = P0(i);
    
    %use an odd number here to ensure the pitch mark is centered in the
    %extracted segment
    L = 2*local_P0 + 1;
    
    %locate the segment to extract from the original signal and then get it
    %and window it
    segment_start = pitch_marks(i) - local_P0;
    segment_end = pitch_marks(i) + local_P0;
    windowed_segment = hanning(L, 'symmetric') .* x(segment_start:segment_end);
    
    %determine where we put things in the output signal
    y_start = output_pitch_mark - local_P0;
    y_end = output_pitch_mark + local_P0;
    
    if y_end > length(y)
        %we've come to the end so there's nothing left to process
        break
    end
    
    %at this point we have the windowed segment and all that is left to do
    %is perform the overlap and add part of the algorithm
    y(y_start:y_end) = y(y_start:y_end) + windowed_segment;
    
    %determine the next pitch mark based on the pitch scaling parameter
    output_pitch_mark = round(output_pitch_mark + local_P0/beta);
end
end