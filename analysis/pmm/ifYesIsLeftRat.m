function [out]=ifYesIsLeftRat(subjectID,dateRange)
%returns true if rat is "yes" is left

lefts={'227','228','231','232','274'}; % left, bigger tilt too
rights={'138','139','229','230','233','234','237'}; 
fakeRights={'136','137'}; % go to sides mapped onto right
knownList=[lefts rights fakeRights];

%if known rat, take it from thsi list
if  any(strcmp(subjectID,knownList))
    switch subjectID
        case lefts
            out=true;
        case rights
            out=false;
        case fakeRights
            out=false;
        otherwise
            error('never happens')
    end


else % look it up

    if ~ exist('dateRange','var') || isempty(dateRange)
        dateRange=[]; % all
    end

    d=getSmalls(subjectID,dateRange);
    [junk type]=addYesResponse(d);

    switch type
        case 'leftMeansYes'
            out=true;
        case 'rightMeansYes'
            out=false;
        otherwise
            d
            d.info
            error('bad')
    end
end
