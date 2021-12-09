function pitch_marks = getPitchMarks(x, Fs, F0, hop, frame_length)

%pre-allocate a buffer assuming worst case scenario of constant Nyquist
%rate signal so the loop can execute more efficiently. trim the unncessary
%components after the analysis part of the algorithm completes
pitch_marks = zeros(1, length(F0)/2);
 
for i = 1:length(F0)
   i1 = 1 + (i-1)*hop;
   i2 = i1 + frame_length;
end

end

