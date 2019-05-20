clear; close all; clc; 


%% Calculating pseudo FMC data

%In this exercise, you will use a pre-written function, fn_simulate_data_v2,
%to synthesise the FMC data from a specified ultrasonic array when
%looking at various samples.

%Your task is to specify an appropriate array, centre frequency and write
%the necessary code to convert the FMC data into an image. The
%ultimate goal is to obtain and analyse the image when
%fn_simulate_data is used with code = 'XXX' where 'XXX' is your initials.
%The sample in this case contains a number of cracks and point reflectors
%in various patterns, including 2 digits.

%When you formed an image of this sample, you should consider questions
%such as:
% - Can you resolve the most closely-spaced point reflectors? How do you
% assess this?
% - Can you estimate the lengths of the cracks from the image? If so, how?
% - Can you tell what digits are present?
% - What is the smallest number of elements needed in an array to obtain
% adequate images?

%The region of interest in all samples is from x = -20 to 20 mm and from 
%z = 10 to 90 mm, but you will probably want to create a slightly larger 
%image. The speed of sound in the target is 5000 m/s.

%The parameters 'no_elements', 'element_pitch', 'el_width' and 
%'centre_freq' describe the array and should be in SI units (i.e. m, Hz). 
%The array has to satisfy the following manufacturing limits:
% - maximum number of elements: 128
% - minimum element width: 0.1 mm
% - maximum element width: 4.0 mm
% - minimum gap between elements: 0.05 mm (i.e. element_pitch - el_width >=
%   0.05mm).
% - centre frequency must be in the range 1 to 10 MHz

%For the 'sample' parameter use either:
% - 'TEST POINTS' to return the FMC data from a sample with 5 point targets 
%   across the region of interest with no noise present
% - 'TEST CRACK' to return the FMC data from a sample with a 5mm long crack
%   in the centre of the region of interest with no noise present
% - 'TEST NUMBERS' to return the FMC data for a sample containing point 
%   targets representing the digits 1-9 in the region of interest with no 
%   noise present
% - 'XXX' where 'XXX' is your initials to return the FMC data for the 
%   blind trial sample containing various cracks, point reflectors and noise.
%   Adding '+NOISE' to any of the first three sample strings (e.g. 
%   'TEST POINTS+NOISE') will return the same FMC data with additional 
%   noise at the same level as the noise for the blind trial sample. 

%Your chosen array parameters go here:
no_elements = 128; 
element_pitch = 2.5e-3;
element_width = 2.45e-3; 
centre_freq = 1e6;

%set code to the appropriate code for the sample for which you wish to simulate data

%Determining what initials the user has
prompt = {'What are your initials?'};
title = 'Initials?';
dims = [1 35];
definput = {'EAF'};
response = inputdlg(prompt,title,dims,definput);
clear title

%Determining what sample you have
prompt = {'What sample would you like to simulate?'};
title = 'Sample?';
list = {'TEST POINTS','TEST CRACK','TEST NUMBERS',...                   
'TEST POINTS+NOISE','TEST CRACK+NOISE','TEST NUMBERS+NOISE'};
list(1,end+1) = response;
[indx,tf] = listdlg('ListString',list,'PromptString',prompt,'name',title);
clear title

sample = char(list(1,indx));

%Call the encrypted function to simulate the FMC data
[time, time_data, element_positions] = fn_simulate_data(sample, no_elements, element_pitch, element_width, centre_freq);

%The fn_simulate_data function returns the following parameters:
% - 'time' is an m-by-1 column vector representing the time-axis of every 
%   A-scan in the FMC data
% - 'time_data' is a m-by-no_elements-by-no_elements 3D array containing 
%   the FMC data itself. The dimensions represent time, transmitter number 
%   and receiver number. Therefore time_data(:, 7, 3)) is the A-scan for 
%   transmitter element 7 and receiver element 3.
% - 'element_positions' is a 1-by-no_elements row-vector of array element 
%   x-coordinates, centred on x = 0. Therefore in the example case of 
%   time_data(:, 7, 3), the transmitting element is at element_positions(7)
%   and the receiving element is at element_positions(3).

%Example of a simulated A-scan from the FMC data
figure(01);
transmitter_index = 7; %this is just an arbitrary choice as an example
receiver_index = 3; %this is just an arbitrary choice as an example
plot(time, time_data(:, transmitter_index, receiver_index));
title(sprintf('Time signal for transmitter %i to receiver %i', transmitter_index, receiver_index));
xlabel('Time (s)');

%Now write your own code to convert this data into an image ...
%% Filtering the data

%Determining if the user wishes the data to be filtered
prompt = {'Would you like the FMC data to be filtered? (1=Yes, 0=No)'};
title = 'Filtering?';
dims = [1 35];
definput = {'1'};
response = inputdlg(prompt,title,dims,definput);
filtering = str2double(response);
clear title

%Deterimining the sample contains noise
Substring = 'NOISE';
Substring2 = char(list(1,length(list)));
noise_present = ~contains(sample, Substring);
initials_present = ~contains(sample, Substring2);

%Perfoming filtering if required
if noise_present == 0 && filtering == 1 || initials_present == 0 && filtering == 1
    filtered_voltage = zeros(size(time_data,1),size(time_data,2),size(time_data,3));

    %Bandpass Filtering of original signal
    for ii = 1:size(time_data,3)
        filtered_voltage(:,:,ii) = fn_freq_bandpassfilter(time_data(:,:,ii), time, centre_freq);
    end

    time_data = filtered_voltage;

    %Example of filtered data
    figure(02);
    transmitter_index = 7; %this is just an arbitrary choice as an example
    receiver_index = 3; %this is just an arbitrary choice as an example
    plot(time, time_data(:, transmitter_index, receiver_index));
    title(sprintf('Filtered Time signal for transmitter %i to receiver %i', transmitter_index, receiver_index));
    xlabel('Time (s)');
end

%% Defining Waveproperties
velocity = 5e3;
wavelength = velocity/centre_freq;
sampling_freq = 1/(time(2)-time(1));

%% Defining Grid Spatial Properties
grid_size = 100e-3;
grid_pts = 1000;

x = linspace(-grid_size/2, grid_size/2, grid_pts);
z = linspace(0,grid_size,grid_pts);
[X,Z]=meshgrid(x,z);

%% Calculating TFM data
%Initialising Arrays
distance = zeros(length(z),length(x));
distance_T=zeros(length(z),length(x));
distance_R=zeros(length(z),length(x));
image = zeros(length(z),length(x));

%Determining what GPU the user has
prompt = {'Does your PC have a Nvidia GPU (1=Yes, 0=No)?'};
title = 'GPU Type?';
dims = [1 35];
definput = {'0'};
response = inputdlg(prompt,title,dims,definput);
pretend_cuda = str2double(response(1,1));
clear title

%Converting arrays to the GPU if applicable
if pretend_cuda == 1
    time_data = gpuArray(time_data);
    Z = gpuArray(Z);
    X = gpuArray(X);
    distance = gpuArray(distance);
    distance_T=gpuArray(distance_T);
    distance_R=gpuArray(distance_R);
    image = gpuArray(image);
end

%Initialising loop variables
time_taken = 0;
num_print_dots = 20;
num_2_print = round(linspace(1,num_print_dots,no_elements));

%Calculating Tx Ray Path
%note: Could maybe do this with arrays and not a for loop
for ii = 1:no_elements
    tic
    distance_T=sqrt(((X-element_positions(ii)).^2)+(Z.^2));         %Pythagoras from grid to tranducer positions 
    
    %Calculating Rx Wave Path
    for jj = 1:no_elements 
        distance_R=sqrt(((X-element_positions(jj)).^2)+(Z.^2));     %Pythagors from grid to each indivial trandcuse position
        distance = distance_T + distance_R;                         %Summation of total distance from each transmit and receive
        T = distance/velocity;                                      %Computing time taken of each path
        test=min(max(round...                                       %Computing the closest index in of sampled time for the time of each path
            (T*sampling_freq),1),length(time));
        curr=time_data(:,ii,jj);                                    %Current FMC data set of concern
        image=image+curr(test);                                     %Summing Image Value on each iteration
    end
    
    %Not necessary but never done one of these before
    %Probably slows down the code somewhat
    %¯\_(?)_/¯
    time_taken = time_taken+toc;
    est_time = (no_elements - ii) * time_taken/ii;
    clc;
    fprintf('Imaging TFM \n');
    fprintf('Processing TX %d of %d\n',ii,no_elements);
    fprintf('%.2f seconds remaining\n',est_time); 
    dots = repmat('.',[1,num_2_print(ii)]);
    spaces = repmat(' ',[1,num_print_dots-num_2_print(ii)]);
    fprintf('[%s%s]\n'...
        ,dots,spaces);
end

%% Refining and Plotting FMC Image
image_original = gather(image);
image = abs(image)/max(max(abs(image)));                        %Normalising the image data to the max
image = 20*log10(image);                                        %Converting to dB scale
image = gather(image);                                          %Gathering from GPU

%Ploting image
figure(03)
clf
imagesc(x,z,image)
colorbar;
colormap('jet');
caxis([-20 0]);
title('TFM Image of Simulated FMC Data [dB]');
xlabel('Z Position [mm]')
ylabel('X Position [mm]')

%Appliying Median Filtering to image
%Very basic image processing
if noise_present == 0 || initials_present == 0
    J = medfilt2(image,[10 10]);
    figure(04)
    clf
    imagesc(x,z,J)
    colorbar;
    colormap('jet');
    caxis([-20 0]);
    title('TFM Image of Simulated FMC Data - Filtered Image [dB]');
    xlabel('Z Position [mm]')
    ylabel('X Position [mm]')
end

%% Calculating Image Metrics
%Performed on the following logic
%Get the signal - that's your "true" noiseless image.
%Get the noise - that's your actual noisy image minus the "true" noiseless image.
%Power Defintion
%Divide them element by element, then take the mean over the whole image
%Voltage Definition
%Divide them element by element, then take the RMS over the whole image

%The above is idealised and assumes you know the 'true' noiseless signal
%How do you do this for real life case when all you have is noisey signal?
%contact e.foster@strath.ac.uk if you know. I would also like to know :)

if noise_present == 0

    %Determing if metric case has been used & loading in noiseless image
    if no_elements == 64 && element_width == 0.9e-3 && element_pitch == 1e-3 && centre_freq == 2e6

        if strcmp(sample,'TEST POINTS+NOISE') == 1

            fname = 'TESTPOINTS2MHZ.mat';
            load(fname);

        elseif strcmp(sample,'TEST CRACK+NOISE') == 1

            fname = 'TESTCRACK2MHZ.mat';
            image_noiseless = load(fname);

        elseif strcmp(sample,'TEST NUMBERS') == 1

            fname = 'TESTNUMBERS2MHZ.mat';
            image_noiseless = load(fname);

        end

        %Based off voltage definition
        noise = image_original - image_noiseless;
        SNR = round(20*log10(rms(rms(image_noiseless/noise))),2);
        
        fprintf('Signal to noise ratio of image is %d \n', SNR);

    end
end