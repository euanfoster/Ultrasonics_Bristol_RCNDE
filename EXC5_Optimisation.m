close all
clear all

%% Assigning a no elements v cost to assign a performance factor
X = [8 128];
Y1 = [0.5 1];
Y2 = [1,0.5];

m1 = (Y1(2)-Y1(1))/(X(2)-X(1));
m2 = (Y2(2)-Y2(1))/(X(2)-X(1));

c1 = Y1(1) - (m1*X(1));
c2 = Y2(1) - (m2*X(1));

x = 8:2:128;
y1 = m1.*x + c1;
y2 = m2.*x + c2;

figure
plot(x,y1)
xlim([8 128])
ylim([0 1])
xlabel('Number of Elements')
ylabel('Assumed Normalised Cost of Manufacture')
title('No of Elements V Cost of Manufacture')

figure
plot(x,y2)
xlim([8 128])
ylim([0 1])
xlabel('Number of Elements')
ylabel('Cost Factor')
title('No of Elements V Cost Factor') 

%% Calculating a no of elements v field intensity function to assign a performance factor
elements = 8:2:128;
field_intensity = zeros(length(elements),1);

for ii = 1:length(elements)
   field_intensity(ii) = fn_huygens(elements(ii));
end

%Transposing and normalising the data
field_intensity = field_intensity';                     
field_intensity = field_intensity./max(field_intensity);

figure
plot(elements,field_intensity)
xlabel('Number of Elements')
ylabel('Field Intensity Factor')
title('Number of Elements V Intensity Factor')

%% Specifying a frequency V SNR function to assing a perfomance factor
frequency = [1 2 3 4 5 6 7 8 9 10];
SNR = [4.87 12.74 7.25 -4.9 -16.6 -14.4 -5.47 -7.7 -8.97 -17.7];

figure
scatter(frequency,SNR)
xlabel('Frequency [MHz)')
ylabel('SNR (dB)')
title('Frequency V SNR')
legend('Scatter Plot','7 Order Curve Fit')



%% Refining parameters so that only array values are returns within the contrains on the question
%Defining Parameters Given in Question
velocity = 5000;
min_gap = 0.05e-3;
min_element_width = 0.1e-3;
max_element_width = 4e-3;

%Calculating Pitch Range
%Assumes you want widest element for best focusing so min_gap = gap
min_pitch = min_element_width+min_gap;
max_pitch = max_element_width+min_gap;

%Calculating Wavelength Range
%From Huygens having a pitch of wavelength/2 is a good assumption
min_lambda = min_pitch*2;
max_lambda = max_pitch*2;

%Calculating Frequency Range
max_frequency = velocity/min_lambda;
min_frequency = velocity/max_lambda;

%Checking if Frequency Range is within question Parameters
if max_frequency > 10e6
    max_frequency = 10e6;
end
if min_frequency < 1e6
    min_frequency = 1e6;
end

%Refining Frequency range to multiples of 0.05Mhz
freq_step = 0.05e6;
max_frequency = round(max_frequency/freq_step)*freq_step;
min_frequency = round(min_frequency/freq_step)*freq_step;

%% Calculating the element width in the array
%assumes that the pitch is Lambda/2

%Calculating element width over applicable freq range
frequency = min_frequency:freq_step:max_frequency;
frequency = frequency';
lambda = velocity./frequency;
pitch = lambda./2;
frequency = frequency/1e6;
SNR = (-0.0033.*frequency.^7) + (0.13.*frequency.^6)...
    - (2.2.*frequency.^5) + (18.*frequency.^4) - (83.*frequency.^3)...
    + (1.9e2.*frequency.^2) + (2e2.*frequency) + 83;
SNR = SNR/max(SNR);

figure
plot(frequency,SNR)
xlabel('Frequency (MHz)')
ylabel('Normalised SNR')
title('Frequency v Normalised SNR')

%Converting to mm
pitch = pitch*1e3;
min_gap = min_gap*1e3;
element_width = pitch-min_gap;

elements = 8:2:128;

performance_factor = zeros(length(element_width),length(elements));
element_width_factor = element_width./max(element_width);

for ii = 1:length(elements)
    performance_factor(:,ii) = element_width_factor.*y2(ii)*field_intensity(ii)*SNR(ii);
end

surf(elements,frequency,performance_factor)
xlabel('Number of Elements')
ylabel('Frequency (MHz)')
zlabel('Perfomance Factor')
title('Array Optimisation')
shading interp

[row,col] = find(performance_factor == max(max(performance_factor)));

fprintf('The optimum array performance is given with %d elements, with a centre frequency of %e MHz, an element width of %f mm and a gap of %g mm\n', elements(1,col), frequency(row,1),element_width(row,1),min_gap);
