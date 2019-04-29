function window = fn_hanning(number_of_points, peak_pos_fract, half_width_fract, varargin);
%USAGE
%	fn_hanning(number_of_points, peak_pos_fract, half_width_fract)
%AUTHOR
%	Paul Wilcox (2003)
%SUMMARY
%	Creates a hanning window
%OUTPUTS
%	window - the generated window function, with amplitude ranging from 0 to 1
%INPUTS
%	number_of_points - how many points are in the window vector
%	peak_pos_fract - where abouts the peak of the window is as a fraction
%	of the total length of the window vector
%	half_width_fract - how wide the halfwidth of the window is as a fraction of
%	the total length of the window vector
%NOTES
%	output is a column vector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x = linspace(0, 1, number_of_points)';
y = 0.5 * (1 + cos((x - peak_pos_fract) / half_width_fract * pi));
window = y .* ((x >= (peak_pos_fract - half_width_fract)) & (x <= (peak_pos_fract + half_width_fract)));

return;
