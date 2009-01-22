function retval = generateFactorialCombo(params, selection, toReturn, mode)
% This function produces a factorial combination of params to facilitate sweeping through parameters in stimulus managers
% INPUTS:
%   params - either a cell array of vectors or a struct
%   selection - either a vector of indices into params that indicates which vectors to include in the combination OR
%               a cell array of field names that indicates which vectors to include (if params is a struct)
%               (defaults to all params)
%   toReturn - same as selection, but these indicate which params to return in retval (by default same as selection)
%   mode - indicates what mode to use to make the combination - default is {'ordered'}
%           other modes might be {'random',[seed]} - the mode is provided as a cell array to allow passing of parameters for the given mode

type=[];
% ======================================================================
% argument checking
% check that params is either a cell array of vectors or a struct
% and then check that selection and toReturn fit params
if iscell(params)
    % check to see params are vectors
    allAreVectors=cellfun(@isvector,params);
    if ~all(allAreVectors)
        error('params must be a cell array of vectors');
    end
    % check that selection matches params
    if ~exist('selection','var') || isempty(selection)
        % set default selection to be all params
        warning('using default selection');
        selection=1:length(params);
    elseif ~isvector(selection)
        error('selection must be a vector');
    end
    if min(selection)<1
        error('selection cannot contain a value < 1');
    elseif max(selection)>length(params)
        error('selection cannot contain a value greater than the number of params');
    end
    % check that toReturn also matches params
    if ~exist('toReturn','var') || isempty(toReturn)
        % set default toReturn to be selection
        warning('using default toReturn');
        toReturn=selection;
    elseif ~isvector(toReturn)
        error('toReturn must be a vector');
    end
    if min(toReturn)<1
        error('toReturn cannot contain a value < 1');
    elseif max(toReturn)>length(params)
        error('toReturn cannot contain a value greater than the number of params');
    end
elseif isstruct(params)
    % check that selection is a cell array of fieldnames
    if ~exist('selection','var') || isempty(selection)
        warning('using default selection');
        selection=fieldnames(params);
    elseif iscell(selection)
        if ~all(ismember(selection,fieldnames(params)))
            selection
            fieldnames(params)
            error('some elements of selection are not found in params');
        end
    else
        error('selection must be a cell array of fieldnames');
    end
    % check that toReturn is a cell array of fieldnames like selection, or that it is a vector of indices into selection
    if ~exist('toReturn','var') || isempty(toReturn)
        warning('using default toReturn');
        toReturn=selection;
    elseif iscell(toReturn)
        if ~all(ismember(toReturn,fieldnames(params)))
            toReturn
            fieldnames(params)
            error('some elements of toReturn are not found in params');
        end
    elseif isvector(toReturn)
        if min(toReturn)<1 || max(toReturn)>length(fieldnames(params))
            error('toReturn cannot contain indices that exceed the number of fields in params');
        end
    else
        error('toReturn must be a cell array of fieldnames or a vector of indices into selection');
    end
    % now check that params's fieldnames that are specified in selection are all vectors
    for i=1:length(selection)
        fn=selection{i};
        if ~isvector(params.(fn))
            error('params contained a field %s that was in selection but is not a vector', fn);
        end
    end    
end % end error checking statement
% check that mode is valid
if ~exist('mode','var') || isempty(mode)
    warning('using default mode of ''ordered''');
    mode={'ordered'};
    type='ordered'; %pmm fixed 01/10/09
elseif iscell(mode)
    % check that mode is a valid mode - so far just {'ordered'}
    if length(mode)==1 && strcmp(mode{1}, 'ordered')
        % 'ordered' mode
        type='ordered';
    elseif strcmp(mode{1}, 'random')
        % 'random' mode
        type='random';
    else
        mode
        error('invalid mode specified');
    end
else
    error('mode must be a cell array or empty');
end
% DONE ERROR CHECKING

% selection should include anything in toReturn that is not already in the selection
% we can do this because we will filter out based on toReturn later
selection=union(selection,toReturn);
% ======================================================================
% now if params was a struct, convert params to the selected fields so that we dont have a long switch statement
% this means that in the case of a struct, we essentially force selection to be all the fields in params (since we are resetting params)
if isstruct(params)
    newParams={};
    for i=1:length(selection)
        newParams{end+1}=params.(selection{i});
    end
    % build new toReturn based on finding members of toReturn in selection (since params is now only those in selection)
    [tf newToReturn] = ismember(toReturn,selection);
    params=newParams;
    selection=1:length(params); % reset selection to be indices into all elements of the new params
    toReturn=newToReturn;
else
    % renumber toReturn based on selection
    [tf toReturn] = ismember(toReturn,selection);
end
% ======================================================================
% now generate combination in cell array mode
% retval will be a MxY matrix, where M is the number of params selected (rows), and Y is the number of combinations
% (cumulative product of the lengths of all selected params)
numParamsSelected=length(selection);
numCombinations=1;
for i=1:length(selection)
    numCombinations=numCombinations*length(params{selection(i)});
end
% ir=length(selection):-1:1;
ir=selection(end:-1:1);

[retval{ir}] = ndgrid(params{ir}) ;
% concatenate
retval = reshape(cat(numParamsSelected+1,retval{:}),[],numParamsSelected);
retval = retval';

% add handling to different modes
% random mode
switch type
    case 'random'
        % mode should be {'random',[seed]}
        if length(mode)==2
            seed=mode{2};
        elseif length(mode)==1
            warning('using default seed of 1 in random mode');
            seed=1;
        else
            error('''random'' mode requires a mode argument of length 2');
        end
        % now reseed matlab's rand generator with the provided seed, and then do a permute
        oldSeed=rand('twister');
        rand('twister',seed);
        order=randperm(size(retval,2));
        retval=retval(:,order);
        % now restore the oldSeed
        rand('twister',oldSeed);
    otherwise
        % do nothing
end
        

% ======================================================================
% now only return the selected rows (toReturn)
retval=retval(toReturn,:);

end % end function
    