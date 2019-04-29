function window = fn_hanning_lo_pass(no_pts, start_fall_fract, end_fall_fract);
%USAGE
%	window = fn_hanning_lo_pass(no_pts, start_fall_fract, end_fall_fract);
%SUMMARY
%	Produces a bandpass filter window with Hanning tapers at ends
%INPUTS
%	no_pts - number of points in output
%	start_fall_fract - the position (from 0 to 1) where the window starts
%	to fall from unity
%	end_fall_fract - the position (from 0 to 1) where the window falls back
%	to zero
%OUTPUT
%	window - the resultant (column) vector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x = linspace(0, 1, no_pts)';
window = 0.5 * (1 + cos(pi * (x - start_fall_fract) / (end_fall_fract - start_fall_fract))) .* (x < end_fall_fract);
window(find(x < start_fall_fract)) = 1;
return;