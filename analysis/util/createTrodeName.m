function trodeStr = createTrodeName(trodeChans)
if ~exist('trodeChans','var')||isempty(trodeChans)||~isnumeric(trodeChans)
    error('trodeChans should be a numeric array');
end
trodeStr = mat2str(trodeChans);
trodeStr = regexprep(regexprep(regexprep(trodeStr,' ','_'),'[',''),']','')
trodeStr = sprintf('trode_%s',trodeStr);
end