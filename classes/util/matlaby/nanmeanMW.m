function out = nanmeanMW(x,d) %my nanmean function shadows the stats toolbox one and is incompatible
if ~exist('d','var') || isempty(d)
    d = 1;
end

% out = builtin('nanmean',x); %fails cuz toolboxes don't count as builtin

fs = which('nanmean','-all');
ind = find(~cellfun(@isempty,strfind(fs,'stats')));
if ~isscalar(ind)
    error('couldn''t find unique stats toolbox nanmean')
end
% out = feval(fs{ind},x); %fails cuz exceeds MATLAB's maximum name length of 63 characters
% f = str2func(fs{ind}); %paths aren't valid function names?
oldDir = cd(fileparts(fs{ind}));
out = nanmean(x,d);
cd(oldDir);
end