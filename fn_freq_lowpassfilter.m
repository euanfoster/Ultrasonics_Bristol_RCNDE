function  [filtered_voltage] = fn_freq_lowpassfilter(voltage, time, f_centre)
%USAGE
%	[filtered_voltage] = fn_freq_lowpassfilter(voltage, time, f_centre)
%AUTHOR
%	Euan Foster (2019)
%SUMMARY
%	Performs a low pass filter on signal 6dB about the centre frquency of
%	the transducer. Returns a filtered signal in the time domain
%OUTPUTS
%	Outputs a filtered signal in the time domain with only the low
%	frequencies of interest present at the same sample length as the
%	original signal
%INPUTS
%	voltage - sampled voltage values
%	time    - sampled time values
%	f_centre - centre frequency of transducer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%performing the FFT of the voltage array.
n = 2^nextpow2(size(voltage,1));
Y = fft(voltage,n,1);
f = 1/(time(2)-time(1))*(0:(n/2-1))/n;
f = f';
P = abs(Y/n);
P = P(1:n/2,:);

%Calulating a window to filter the data with a low pass filter
%Can easily be adjusted for other windowing fucntions
%Assumes a 6 dB drop about the centre frequency
freq_mag_drop = f_centre/(10^(6/20));
j = find(f>=f_centre,1,'first');
k = find(f>=f_centre+freq_mag_drop,1,'first');
window = fn_hanning_lo_pass(n/2,j/(n/2),k/(n/2));

%checks
%plotting half of the first column of the abs spectra voltage values
% figure(03)
% clf
% yyaxis left
% plot(f,P(:,1))
% yyaxis right
% plot(f,window)
% legend('Freq Magnitude','Window');
% title('Half Frequency Spectra and Window');

%Doubling the window to match mirroring effect of the fft
window =[window; flip(window)];
%caulculating the filtered singal over the full spectra content
filtered_spectra = Y.* window; 

%checks
%plotting the full first column of the abs voltage spectra and window
% figure(03)
% clf
% yyaxis left
% plot(abs(Y(:,1)/n));
% hold on
% yyaxis right
% plot(window);
% legend('Freq Magnitude','Window');
% title('Full Frequency Spectra and Window');

%checks
%plotting the full first column of the abs filtered vthe moltage spectra and window
% figure(04)
% clf
% yyaxis left
% plot(abs(filtered_spectra(:,1)/n));
% hold on
% yyaxis right
% hold on
% plot(window);
% title('Filtered Frequency Spectra and Window');
% legend('Freq Magnitude','Window');

%converting back to the time domain on full Frequency Spectra
filtered_voltage = real(ifft(filtered_spectra,n));
filtered_voltage = filtered_voltage(1:length(time),:);
end