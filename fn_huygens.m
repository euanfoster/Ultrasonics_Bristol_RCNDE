function central_field_intensity = fn_huygens(no_elements)
%USAGE
%	central_field_intensity = fn_huygens(no_elements);
%SUMMARY
%	Produces a huygens field and returns a value that is summed 10mm about
%	the centre of the field
%AUTHOR
%	Euan Foster (2019)
%INPUTS
%	no_elements - number of elements
%OUTPUT
%	central_field_intensity - the amplitude of the field summed 10mm about
%	the centre of the field

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%wave parameters
velocity = 5e3; 
frequency = 2e6;
lambda = velocity/frequency;

%transducer details
pitch = lambda/2;
transducer_width = 64*pitch + pitch; 
source_x_positions = linspace(-transducer_width/2 ,transducer_width/2,no_elements);

grid_size = round(transducer_width/10e-3)*10e-3 + 100e-3;
grid_pts = grid_size*1000;

%set up output grid
x = linspace(-grid_size/2, grid_size/2, grid_pts);
y = linspace(0,grid_size,grid_pts);

%set up sources for transducer

%prepare output matrix
p = zeros(length(y),length(x)); %TO BE ENTERED

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

k = 2*pi/lambda;

p = (1/sqrt(r_value)).*exp(1i*k*r_value);
p = sum(p,3);
p = abs(p);

% plot field
% figure()
% clf
% imagesc(y,x,p)
% title('Ultrasonic Field Intensity from Huygens Principle');
% caxis ([ 0 90 ])

%Calculating central field intensity
ii = size(p,1)/2;
jj = ii - 5;
kk = ii + 5;
central_field_intensity = sum(sum(p(jj:kk,:)));

end