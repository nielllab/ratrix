function    [value]  = canForceStimDetails(stimManager,forceStimDetails)
% returns true if the stimulus manager has a optional arguument in calcStim
% that forces the stimulus details to apply. Only managers that impliment
% this feature should return true, and they should be able to error check
% the force detail requests to confrim that they are valid requests... for
% example, you can request a field to change that does not exist on that
% stimulus


%each stimManager keeps track of the list of stimDetails that it allows to
%be set.  requests to set other feilds are denied

settableDetail={'targetOrientation','flankerOrientation',...
    'flankerContrast','targetContrast',...
    'flankerPosAngle','pixPerCycs','flankerPhase'...
    'mean','stdGaussMask','flankerOffset','pixPerCycs'};

if ~exist('forceStimDetails')
    value=true;
else
    %check the struct:
    if ~strcmp(class(forceStimDetails),'struct')
        class(forceStimDetails)
        error('forceStimDetails must be a struct')
    end

    %check the fields:
    f=fields(forceStimDetails);
    for i=1:length(f)
        switch f{i}
            case 'flankerPosAngles'
                if ~all(size(forceStimDetails.flankerPosAngles)==[1 2]) & isnumeric(forceStimDetails.(f{i}))
                    error('must have two numbers for the flankers')
                end
            otherwise
                if ~any(strcmp(settableDetail,f{i}))
                    f{i}
                    error('that detail is not settable')
                end
                if ~all(size(forceStimDetails.(f{i}))==1) & isnumeric(forceStimDetails.(f{i}))
                    fieldName=f{i}
                    values=forceStimDetails.(f{i})
                    error('all details must be a single number')
                    %thsi test is only currently true for ifFeature, need not be
                    %true for oter stims
                end
        end
    end
    
    %passes tests to get here, so:
    value=true;
end