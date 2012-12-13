function out = builtinEF(varargin)
f = varargin{1};
t = varargin{2};
varargin = varargin(3:end);

% out = builtin('nanmean',x); %fails cuz toolboxes don't count as builtin

fs = which(f,'-all');
ind = find(~cellfun(@isempty,strfind(fs,t)));
if ~isscalar(ind)
    error('couldn''t find unique')
end
% out = feval(fs{ind},x); %fails cuz exceeds MATLAB's maximum name length of 63 characters
% f = str2func(fs{ind}); %paths aren't valid function names?
oldDir = cd(fileparts(fs{ind}));
out = feval(f,varargin{:});
cd(oldDir);
end