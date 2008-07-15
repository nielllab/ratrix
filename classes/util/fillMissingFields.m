function x=fillMissingFields(y,whichFields,value)
%this is used if you want to horzcat a struct within a struct that has
%unlike fields, ex: x=y.a, but y.a has inconsistent fields, all fields that
%are missing will be added as the value.
%
%this function is NOT recursive, and only acts two deep 
%
%x=fillMissingFields(y,whichFields,value)
%trialRecords=fillMissingFields(trialRecords,{'stimDetails'},nan)
%
%pmm 08/05/24

if ~exist('value', 'var')
    value=nan;
end

if ~exist('whichFields', 'var')
    whichFields=fields(y);  %do all of them
end

ln=length(y);
numfilledStructures=length(whichFields);
for j=1:numfilledStructures

    %reinit per structure
    allFields={};

    %find all the fields
    for i=1:ln
        allFields=union(allFields, fields(y(i).(whichFields{j})));
    end

    %add "missing value" for every missing field
    for i=1:ln
        missing=setdiff(allFields, fields(y(i).(whichFields{j})));
        numMissing=length(missing);
        for k=1:numMissing
            y(i).(whichFields{j}).(missing{k})=value;
            %disp(sprintf('i:%d j:%s k:%s',i, whichFields{j}, missing{k}))
        end
    end
end

x=y;