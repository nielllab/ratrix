function [reigons,cons4Legend,cons4axes,durs4Legend,durs4Axes] = getSubtitleLegendNaxesInfo(uniqueContrasts,uniqueDurations)
% figure title, legend, & axes info. Inputs made in prev function

% subplot titles
reigons = {'V1','LM','RL','AM','control'};

% legend & axes
cons4Legend = arrayfun(@num2str, uniqueContrasts, 'UniformOutput', 0); % max contrast is '1'
% from online: The NUM2STR function converts a number to the string representation of that 
% number. This function is applied to each cell in the A array/matrix using ARRAYFUN. 
% The 'UniformOutput' parameter is set to 0 to instruct CELLFUN to encapsulate the outputs 
% into a cell array.
cons4axes = arrayfun(@num2str, uniqueContrasts*100, 'UniformOutput', 0); % max contrast is 100% 

durs4Legend = arrayfun(@num2str, uniqueDurations, 'UniformOutput', 0);
durs4Axes = arrayfun(@num2str, uniqueDurations, 'UniformOutput', 0);

%cons4Legend = {'0','0.03','0.063','0.125','0.25','0.5','1'};
%cons4Axes = {'0','3','6','12','25','50','100'};
%durs4Legend = {'16 ms','33 ms','66 ms','133 ms','266 ms'};
%durs4Legend = {'66 ms','83 ms','100 ms','133 ms'};
%durs4Axes = {'16','33','66','133','266'};
%durs4Axes = {'66','83','100','133'};

end

