function window = fn_hanning_band_pass(no_pts, start_rise_fract, end_rise_fract, start_fall_fract, end_fall_fract);
%USAGE
%	window = fn_hanning_band_pass(no_pts, start_rise_fract, end_rise_fract, start_fall_fract, end_fall_fract);
%SUMMARY
%	Produces a bandpass filter window with Hanning tapers at ends
%INPUTS
%	no_pts - number of points in output
%	start_rise_fract - the position (from 0 to 1) where the window starts
%	to rise from zero
%	end_rise_fract - the position (from 0 to 1) where the window rise is
%	completed at unity
%	start_fall_fract - the position (from 0 to 1) where the window starts
%	to fall from unity
%	end_fall_fract - the position (from 0 to 1) where the window falls back
%	to zero
%OUTPUT
%	window - the resultant (column) vector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
window = fn_hanning_hi_pass(no_pts, start_rise_fract, end_rise_fract) .* fn_hanning_lo_pass(no_pts, start_fall_fract, end_fall_fract);
return;

function window = fn_hanning_hi_pass(no_pts, start_rise_fract, end_rise_fract);
x = linspace(0, 1, no_pts)';
window = 0.5 * (1 - cos(pi * (x - start_rise_fract) / (end_rise_fract - start_rise_fract))) .* (x > start_rise_fract);
window(find(x > end_rise_fract)) = 1;
return;

function window = fn_hanning_lo_pass(no_pts, start_fall_fract, end_fall_fract);
x = linspace(0, 1, no_pts)';
window = 0.5 * (1 + cos(pi * (x - start_fall_fract) / (end_fall_fract - start_fall_fract))) .* (x < end_fall_fract);
window(find(x < start_fall_fract)) = 1;
return;