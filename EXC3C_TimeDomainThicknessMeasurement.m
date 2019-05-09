%% Initialising and loading in data

clear; %clear all variables from memory
close all; %close all windows
clc; %clear command window

disp('AUTOMATED TIME-DOMAIN THICKNESS MEASUREMENT'); %display the title

fname = 'bearing_casing_bscan.mat';
load(fname);
max_thickness = 55e-3;

%% Plotting first column of data/first A scan
%plotting first column of data
figure(01)
plot(time*1e6,voltage(:,1))
xlabel('Time (\mus)');
ylabel('Voltage (V)');

%% Filtering data based on centre frequency of Transducer
%Asking user for Centre Frequency of Transducer
prompt = {'What is the centre frequency of the transducer used in Mhz?'};
title = 'Frequency Input';
dims = [1 35];
definput = {'5'};
response = inputdlg(prompt,title,dims,definput);
f_centre = str2double(response(1,1))*1e6;
clear title

%Low pass filtering of original signal
filtered_voltage = fn_freq_lowpassfilter(voltage, time, f_centre);

%% Plotting First Column of filtered data
%plotting the first column of the filtered voltage signal in time domain
figure(02)
plot(time*1e6,filtered_voltage(:,1))
xlabel('Time (\mus)');
ylabel('Voltage (V)');
title('Filtered Signal V Time');
legend('Filtered Signal');

%% Automatic Front Wall and Backwall Detection
%Attempted tp use the fn_wave_packet function to auto detect front and
%backwall. This worked till column 80 of the voltage array and then the
%back wall was too faint to detect.

%If you ideas on how to do this, please let me know: e.foster@strath.ac.uk

%function will run but wont return backwalls for columns 80-95ish
%v_threshold =5e-3; 
%[voltage_wave, time_wave] = fn_wave_packet(filtered_voltage,time,v_threshold); %isolating the waves

%% Time Gating Signal about 45-60 micro seconds & Rectifying Signals
x = find(time==45e-6);
y = find(time==60e-6);

voltage_frontwall = filtered_voltage(1:x,:);
voltage_backwall = filtered_voltage(x+1:y,:);
time_frontwall = time(1:x,:);
time_backwall = time(x+1:y,:);

voltage_frontwall = abs(voltage_frontwall);
voltage_backwall = abs(voltage_backwall);

%% Calulating Envelope & Time of Flight between wavepackets
[up1,lo1] = envelope(voltage_frontwall);
[up2,lo2] = envelope(voltage_backwall);

time_peak_frontwall = zeros(size(voltage,2),1);
time_peak_backwall= zeros(size(voltage,2),1);

for ii = 1:size(voltage,2)
    
    x = find(voltage_frontwall(:,ii)==max(voltage_frontwall(:,ii))); 
    y = find(voltage_backwall(:,ii)==max(voltage_backwall(:,ii)));
    
    time_peak_frontwall(ii,1) = time_frontwall(x,1);
    time_peak_backwall(ii,1) = time_backwall(y,1);  
end

%% Calibrating and calculating thickness

delta_t = time_peak_backwall - time_peak_frontwall;
delta_t = delta_t./2;
speed = max_thickness/max(delta_t);

thickness = speed.*delta_t;
thickness = movmean(thickness,3);

figure(03)
plot(pos,thickness);












