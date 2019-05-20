clear; %clear all variables from memory
close all; %close all windows
clc; %clear command window

disp('Beam profile of a 2D transducer'); %display the title

%INPUTS

%wave parameters
velocity = 6e3;
frequency = 1e6;

%transducer details
transducer_width = 20e-3;
min_sources_per_wavelength = 2;

grid_size = 100e-3;
grid_pts = 100;

%PROGRAM

%set up output grid
x = linspace(-grid_size/2, grid_size/2, grid_pts);%TO BE ENTERED
y = linspace(0,grid_size,grid_pts);%TO BE ENTERED

%set up sources for transducer
wavelength = velocity/frequency;
delta = transducer_width/(wavelength/min_sources_per_wavelength);
source_x_positions = linspace(-transducer_width/2 ,transducer_width/2,delta);%TO BE ENTERED

%prepare output matrix
p = zeros(length(y),length(x)); %TO BE ENTERED

tic
%INSERT LINES FOR THE MAIN CALCULATION HERE

[A,B] = meshgrid(x,y);
c = cat(2,A',B');
grid_coor = reshape(c,[],2);

transducer_coor = zeros(length(source_x_positions),2);
transducer_coor(:,1) = source_x_positions;

r = pdist2(transducer_coor(:,:), grid_coor(:,:));
r_value = zeros(length(y),length(x),length(source_x_positions));

for ii = 1:length(source_x_positions)
   r_value(:,:,ii) = reshape(r(ii,:), [length(y),length(x)]); 
end

k = 2*pi/wavelength;

p = (1/sqrt(r_value)).*exp(1i*k*r_value);
p = sum(p,3);
p = abs(p)/max(max(abs(p)));                        %Normalising the image data to the max
p = 20*log10(p);                                    %Converting to dB scale


%FINISH OF MAIN CALCUALTION
toc

%plot field
imagesc(p)
colorbar
caxis ([ -30 0])
title("Huygen's Field Model [dB]")
xlabel('X Position [mm]')
ylabel('Z Position [mm]')
