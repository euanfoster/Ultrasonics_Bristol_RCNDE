clear; %clear all variables from memory
close all; %close all windows
clc; %clear command window

disp('Frequency domain'); %display the title

%INPUTS

%pulse parameters
number_cycles = 5; %keep
centre_frequency = 1e6; %keep

%wave propagation
nondispersive_propagation = 1;
velocity_at_centre_frequency = 3e3; %keep

%distance
distance_step = (velocity_at_centre_frequency/centre_frequency)/4;  %TO BE ENTERED
max_distance = 150e-3; %keep

%time
time_step = (1/centre_frequency)/10;   %TO BE ENTERED
max_time = (max_distance/velocity_at_centre_frequency)+(number_cycles/centre_frequency);                      %TO BE ENTERED

%PROGRAM

%create time vector of wave packet duration
t = [0 : time_step : max_time];%TO BE ENTERED

%create distance vector
x = [0 : distance_step : max_distance];%TO BE ENTERED

%create Hanning windowed toneburst
time_at_centre_of_pulse =  (number_cycles/centre_frequency)/2;%TO BE ENTERED

%time of wave packet relative to total propigation time

%first number is where the wave ends in time
%second number is where the wave centre is in time
window = fn_hanning(length(t), 0.0455, 0.0455);%TO BE ENTERED
w = 2*pi*centre_frequency;
sine_wave = sin(w*t);%TO BE ENTERED

input_signal = window(:) .* sine_wave(:); %keep

%At this point the input time-domain signal should have been created

%calculate the frequency spectrum of the input pulse
fft_pts = 2.^nextpow2(length(t));          %TO BE ENTERED
spec = fft(input_signal,fft_pts);   %TO BE ENTERED
spectrum = spec(1:fft_pts/2);

%build frequency axis
freq_step = (1/(time_step*fft_pts)); %TO BE ENTERED
freq = [0: freq_step: ((fft_pts/2)*freq_step-1)];    %TO BE ENTERED

figure(01)
plot(freq,abs(spectrum))

%At this point the frequency spectrum of the input time signal should have been created

if nondispersive_propagation == 1
    velocity = velocity_at_centre_frequency; %keep
else
    velocity = 3*(freq.^0.5); %TO BE ENTERED
    velocity(1,1) = 1;
end

figure(03)
plot(freq,velocity)
w=2*pi*freq;

%create a vector of wavenumbers
k = 2*pi*freq./velocity; %TO BE ENTERED
figure
plot(k,w)
c_g=1./gradient(k,(w(2)-w(1)));
figure
plot(freq, c_g)

%prepate a matrix to put the results in
p = zeros(length(input_signal), length(x)); %TO BE ENTERED

%loop through the different distances and create the time-domain signal at
%each one and out into the matrix p
for ii = 1:length(x)%TO BE ENTERED
    delayed_spectrum = spectrum.'.*exp(-1i*k*x(ii));%TO BE ENTERED
    time_dom = real(ifft(delayed_spectrum, fft_pts));
    time_dom = time_dom(:,1:length(input_signal));
    p(:,ii) = time_dom;
    %MORE LINES TO BE ENTERED!
end

figure(02);
for ii = 1:size(p,2)
   clf
   plot(t,p(:,ii));
   ylim([-0.5, 0.5])
   yticks([-0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5])
   pause(0.1)
   M(ii) = getframe(gcf);
end

video = VideoWriter('Frequency.avi','Uncompressed AVI');
open(video)
writeVideo(video,M)
close(video)


