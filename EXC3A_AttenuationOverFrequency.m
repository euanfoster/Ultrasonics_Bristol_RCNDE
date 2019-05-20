%% Initialising and loading in data

clear; %clear all variables from memory
close all; %close all windows
clc; %clear command window

disp('Frequency dependent attenuation of perspex'); %display the title

%file name
fname = '7_8mm_thick_perspex.mat';
sample_thickness = 7.8e-3;

%load file
load(fname);

%% Plotting A Scan Data
%Plotting the data
figure(01)
plot(time * 1e6, voltage);
xlabel('Time (\mus)');
ylabel('Voltage (V)');
title('A Scan - Perspex 7.8mm')
%% Automatically Detecting Each Wave Packet within the A Scan
%PROGRAM
v_threshold = 1.5e-3;                 %Setting a noise floor threshold
[voltage_wave, time_wave] = fn_wave_packet(voltage,time,v_threshold); %isolating the waves
%Transposing matrixes from column to row vectors for FFT
voltage_wave = voltage_wave.';
time_wave = time_wave.';
%calculating the sampling frequency
sampling_freq = 1/(time(2)- time(1));

%% Calculating Frequency Content of Wave
%FFT of isolated waves
n = length(voltage_wave);
f = sampling_freq*(0:(n/2))/n;
Y = fft(voltage_wave,n,2);
P = abs(Y/n);

%% Plotting frequency Spectra of Each Wave Packet
%Plotting Spectra of wave packets over half the calculated FFT
figure(02)
plot(f,P(:,1:n/2+1)) 
xlabel('Freq (Hz)');
ylabel('Magnitude');
title('Frequency Spectra of Front and Back Wall')
legend('Front Wall','Backwall','Reverberation')

%% Calculating attenuation of as a function of Frequency and Distance
%Calculating attentuation over full frequency range
d = 2*sample_thickness;
A_omega = P(2,:)./P(1,:);
alpha = (log(A_omega)*-1)/d;

%Truncating attenuation for frequency range of interest
%Assumes a 12db drop in first echo
%This is equivalent to a full width at half maximum technique
i = find(P(1,:) == max(P(1,:)),1,'first');
freq_mag_drop = f(1,i)/(10^(6/20));
j = find(f>=f(1,i)-freq_mag_drop,1,'first');
k = find(f>=f(1,i)+freq_mag_drop,1,'first');

%Plotting attenuation as a function of relevant frequency content
figure(03)
plot(f(1,j:k)/1e6,alpha(1,j:k))
xlabel('Freq (MHz)');
ylabel('Attenuation (Np/mm)');
title('Frequency V Attenuation')