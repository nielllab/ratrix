function [intensity, rawFirstFrame] = calculateIntensityPerFrame(data, method, samplingRate, ifi, numFramePerValue)
%%%%%% Isolating the boundaries


%%%%% For Rising Edge %%%%%%%%%%%%%%%%%%
pulse_threshold = 2; %was 2;

edge_rise = diff(data(:, 2)) > pulse_threshold; % detecting all the entries that has a difference > 2
edge_rise_index = find(edge_rise ==1); % finds the index of all the rising edges determined by edge_rise
edge_rise_index(find(diff(edge_rise_index) == 1)) = []; % remove pulses that spanned more than 1 sample, keep the last one

edge_fall = diff(data(:, 2)) < -pulse_threshold;
edge_fall_index = find(edge_fall == 1);
edge_fall_index(find(diff(edge_fall_index) == 1)) = [];

% the upper and lower bound of the amount of time to display the needed
% frames

%tolerance = 0.4; % number of frames of deviation from the expected values; if less than 0.5, should catch dropped frames
tolerance = [-3 1]; % broader tolerance while synchronization returns bad ifi's. 
numFramePerValue = double(numFramePerValue);
interval_threshold = round(ifi * [numFramePerValue + tolerance] * double(samplingRate));
interval_threshold

% TODO: check to make sure numFramePerValue is what we expect (dropped frames)

for i = 1:size(edge_rise_index , 1)
    interval = edge_fall_index(i) - edge_rise_index(i);
    
    if interval <= interval_threshold(1)     
        edge_rise_index(i) = 0;
        edge_fall_index(i) = 0;
        interval
        interval_threshold
        i
        plot(data)
        error('interval too short');
    elseif interval >= interval_threshold(2)
        edge_rise_index(i) = 0;
        edge_fall_index(i) = 0;
        i
        interval
        interval_threshold
        plot(data);
        error('interval is too long; must have dropped a frame');
        
    end
end
edge_rise_index = nonzeros(edge_rise_index);
edge_fall_index = nonzeros(edge_fall_index);
% %%%% For Falling Edge %%%%%%%%%%%%%%%%%%%
% 
% 
% 
% for i = 1:size(edge_fall_index , 1)-1
%     interval = edge_fall_index(i+1) - edge_fall_index(i);
%     if interval < interval_threshold(1)     
%         edge_rise_index(i) = 0;
%          
%     elseif interval > interval_threshold(2)
%         edge_rise_index(i) = 0;
%         i
%         plot(data);
%         error('interval is too long; must have dropped a frame');
%         
%     end
% end
% 
% edge_fall_index = nonzeros(edge_fall_index);

pad = round(mean(interval_threshold) * 0.2);
rawFirstFrame = data(edge_rise_index(1) - pad : edge_fall_index(1)+pad, :);

switch method
    case 'integral'
        % If data is negative
%         if any(data(:, 1) <=0)
%             minVal = min(data(:, 1));
%             minVal
%             data(:, 1) = data(:, 1) - minVal;
%             warning('Found Negative Values, modifying sensor Data: Be AWARE the amount of noise in the dark value could act to modulate this offset');
%         end
        %%%%%% Calculating area

        for i = 1:size(edge_fall_index, 1)
            new_data = data(edge_rise_index(i) : edge_fall_index(i), 1);

            area_per_pulse(i) = sum(new_data);

        end

        intensity = area_per_pulse/double(numFramePerValue);
    otherwise
        error('unknown method');
end



