%% Initialising and loading in data for Joint off Case

clear; %clear all variables from memory
close all; %close all windows
clc; %clear command window

disp('FREQUENCY-DEPENDENT REFLECTION COEFFICIENT FROM AN ADHESIVE JOINT'); %display the title

%file name & loading file
fname = 'joint_off_adhesive.mat';
load(fname);

%% Plotting A Scan of Joint off Case
%Plotting the data for no joint
figure(01)
plot(time * 1e6, voltage);
title('Joint off Voltage V Time Plot')
xlabel('Time (\mus)');
ylabel('Voltage (V)');

%% Isolating Each Wave Packet in the A-Scan
v_threshold = 1e-2;                 %Setting a noise floor threshold

[voltage_wave, time_wave] = fn_wave_packet(voltage,time,v_threshold); %isolating the waves
%Transposing matrixes from column to row vectors for FFT
voltage_wave = voltage_wave.';
time_wave = time_wave.';

%Storing joint off wave and time arrays
voltage_wave_jointoff = voltage_wave;
time_wave_jointoff = time_wave;
sampling_freq_jointoff = 1/(time(2)-time(1));

%% Loading in data for joint on case
%file name & loading file
fname = 'joint_on_adhesive.mat';
load(fname);

%% Plotting A Scan of Joint on Case
[voltage_wave, time_wave] = fn_wave_packet(voltage,time,v_threshold); %isolating the waves
%Transposing matrixes from column to row vectors for FFT
voltage_wave = voltage_wave.';
time_wave = time_wave.';

%storing joint on wave and time arrays
voltage_wave_jointon = voltage_wave;
time_wave_jointon = time_wave;
sampling_freq_jointon = 1/(time(2)-time(1));


%% Plotting A Scan of Joint on Case
figure(02)
plot(time * 1e6, voltage);
title('Joint on Voltage V Time Plot')
xlabel('Time (\mus)');
ylabel('Voltage (V)');

%% Calculating FFT of Isolated Waves for Both Cases
%FFT of isolated waves
%Joint off
n = length(voltage_wave_jointoff);
f_jointoff = sampling_freq_jointoff*(0:(n/2))/n;
Y_jointoff = fft(voltage_wave_jointoff,n,2);
P_jointoff = abs(Y_jointoff/n);
P_jointoff_B = P_jointoff(2,1:n/2+1);           %Truncating FFT to half length and only storing backwall

%Joint on
n = length(voltage_wave_jointon);
f_jointon = sampling_freq_jointon*(0:(n/2))/n;
Y_jointon = fft(voltage_wave_jointon,n,2);
P_jointon = abs(Y_jointon/n);
P_jointon_B = P_jointon(2,1:n/2+1); 

%% Plotting Frequency Spectra of Both Cases
figure(03)
plot(f_jointon / 1e6,P_jointon_B,f_jointon / 1e6, P_jointoff_B);
title('Frequency Spectra')
xlabel('Freq (Mhz)');
ylabel('Reflection Coefficient');
legend('Joint on','Joint off')

%% Truncating Frequency Spectra to region of Interest
%Assumes a 12db drop in first echo
%This is equivalent to a full width at half maximum technique
i = find(P_jointon_B(1,:) == max(P_jointon_B(1,:)),1,'first');
freq_mag_drop = f_jointon(1,i)/(10^(6/20));
j = find(f_jointon>=f_jointon(1,i)-freq_mag_drop,1,'first');
k = find(f_jointon>=f_jointon(1,i)+freq_mag_drop,1,'first');
P_jointon_B = P_jointon_B(1,j:k);
P_jointoff_B = P_jointoff_B(1,j:k);

%% Calculating Reflection Coefficient as a Fucntion of Frequency
%Taken from Course Notes
%Density of Materials
rho_alu = 2700;
rho_water = 1000;
%Longitudinal Velocity
v_alu = 6320;
v_water = 1500;

%Acoustic Impedance
z_alu = rho_alu*v_alu;
z_water = rho_water*v_water;

ref_alu_water = (z_alu-z_water)/(z_alu+z_water);

ref_alu_adhesive = (P_jointon_B./P_jointoff_B)*ref_alu_water;

figure(04)
plot(f_jointon(1,j:k) / 1e6, ref_alu_adhesive);
title('Ahesive Bond V Freq Plot')
xlabel('Freq (Mhz)');
ylabel('Reflection Coefficient');

