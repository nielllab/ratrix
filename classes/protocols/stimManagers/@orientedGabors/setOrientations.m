function s=setOrientations(s,t,d)
if all(cellfun(@(f) all(cellfun(@(x) f(x) || isempty(x),{t d})),{@isreal @isvector @isnumeric})) || ...
        (strcmp(d,'abstract') && all(cellfun(@(f)f(t),{@iscell @isvector})) && all(cellfun(@(f) all(cellfun(@(x) f(x) || isempty(x),t)),{@isreal @isvector @isnumeric})))
    s.targetOrientations=t;
    s.distractorOrientations=d;
else
    error('target and distractor orientations must be real numeric vectors or, if distractor orientations is ''abstract'', target orientations must be a cell vector of real numeric vectors')
end