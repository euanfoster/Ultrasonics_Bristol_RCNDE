clear; %clear all variables from memory
close all; %close all windows
clc; %clear command window

disp('Wave Animation 1'); %display the title

%INPUTS

%wave parameters
frequency = 1e6;
velocity = 3e3*2;

%x parameters
x_end = 3e-2;           %TO BE ENTERED%
x_step = 1.5e-4;        %TO BE ENTERED%

%time parameters
t_step = 0.05e-6;   %TO BE ENTERED%
t_points = 100;     %TO BE ENTERED%

%PROGRAM

x = [0 : x_step : x_end];           %make a vector of x positions
t = [0 : t_step : (t_step*t_points)]; %make a vector of times

%calculate w and k from inputs
w = 2*pi*frequency;       %TO BE ENTERED%
k = w/velocity;      %TO BE ENTERED%

figure; %open a new graphics figure
p = zeros(length(x), length(t));

%the animation loop follows
for ii = 1 : length(t)
    p(:,ii) = (exp(((k*x)-(w*t(ii)))*-1i));%TO BE ENTERED%
    clf; %clear the figure
    plot(x, real(p(:,ii)), 'b', x, imag(p(:,ii)), 'r'); %plot u vs. x in blue
    pause(0.1); %pause for 1/100th of a second to allow plotting
end

surf(t,x,real(p))
