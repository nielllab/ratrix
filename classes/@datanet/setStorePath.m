function [datanet] = setStorePath(datanet, path)
if ~ischar(path)
    error('path must be a string')
end
datanet.storepath=path;
end