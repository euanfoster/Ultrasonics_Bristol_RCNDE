function  [voltage_wave, time_wave] = fn_wave_packet(voltage, time, v_threshold)
%USAGE
%	[voltage_wave, time_wave] = fn_wave_packet(voltage, time, v_threshold)
%AUTHOR
%	Euan Foster (2019)
%SUMMARY
%	Identifies and isolates wave packets for a given voltage time trace and
%	noise threshold. The isolated waves are padded with zero values after
%	their voltage and time traces to make good frequency resolution
%OUTPUTS
%	Outputs a voltage and time 2D array that in which each row contains
%	the time and voltage of the wave packet identified
%INPUTS
%	voltage - sampled voltage values
%	time    - sampled time values
%	v_threshold - voltage threshold of noise floor
%NOTES
%This code was to work for 3C also. However, when it gets to column 80 the
%backwall is too faint to be automatically detected by this function. 

%If you have any ideas on how to do this I would like to hear :)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[up1,lo1] = envelope(voltage);                          %Hilbert transform of wave signal
v_binary = up1;                                         %Establishing a binary wave array that is the same size as the voltage and time array
v_binary(v_binary>=v_threshold) = 1;                    %Populating the binary wave 
v_binary(v_binary<v_threshold) = 0;                     %Populating the binary wave
v_binary = medfilt1(v_binary,75,'zeropad');             %Filtering out binary wave windows of insignificant size     
m_binary = diff(v_binary);                              %Absolute value of the column wise gradient
m_binary(size(m_binary,1):size(time,1),:) = 0;          %Making m_binary the same length as voltage/time

[rows, columns] = find(m_binary==1);                    %Identifying where the gradient change occurs - 2 gradient values at start and end of wave
max_packets = sum(columns(:,:)==mode(columns));         %Calculating the max number of wave packets obsered in a wave

ind_start = zeros(max_packets,size(voltage,2));         %Establishing an array to store all the start indexes of the wave packets
ind_end = zeros(max_packets,size(voltage,2));           %Establishing an array to store all the end of the wave packets

%Populating the ind_start & ind_end
for ii = 1:size(voltage,2)
    x = find(m_binary(:,ii)==1);
    y = find(m_binary(:,ii)==-1);
    lenx = length(x);
    leny = length(y);
    ind_start(1:lenx,ii) = x;
    ind_end(1:leny,ii) = y;
end

fft_len = 2^nextpow2(size(time,1));                                     %Establishing a large number
voltage_wave = zeros(fft_len,max_packets,size(voltage,2));              %Setting a 2D voltage array at all points to zero
time_wave =zeros(fft_len,max_packets,size(voltage,2));                  %Setting a 2D time array at all points to zero

%Populating voltage and time array for each wave packet identified
for ii = 1:size(voltage,2)
    for jj = 1:max_packets
        
        if ind_start(jj,ii)~= 0 && ind_end(jj,ii)~= 0
            vol = voltage(ind_start(jj,ii):ind_end(jj,ii),ii);
            len = length(vol);
        
            voltage_wave(1:len,jj,ii) = voltage(ind_start(jj,ii):ind_end(jj,ii),ii);
            time_wave(1:len,jj,ii) = time(ind_start(jj,ii):ind_end(jj,ii),1);
        end
    end
end


end