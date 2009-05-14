function d=convertCTR2vectors(ctr,compiledLUT,compiledDetails)
% put the structured trial records in a vector format. 
% treats details the same as normal values, naning where appropriate
% adds lut into the info field so that its easier to pass around. 
% back compatible with flanker analyasis files
% wrote it   pmm 090112

%init
d.trialNumber=ctr.trialNumber;

%main compiled
d=set(d,ctr);

%add all details
for j=1:size(compiledDetails,2)
    cd=compiledDetails(j).records;
    cd.trialNumber=compiledDetails(j).trialNums;
    d=set(d,cd);
end

% add the look up table of strings
d.info.strLUT=compiledLUT;

function d=set(d,source)
%d= small data, n= numTrials

n=range(d.trialNumber)+1;
inds=source.trialNumber;
f=fields(source);
for i=1:length(f)
    %sz=size(source.(f{i}));
    %disp(sprintf('doing %s which is size [%d x %d]', f{i},sz(1),sz(2)));
    switch class(source.(f{i}))
        case {'double','logical','int8','uint8'}
            if size(source.(f{i}),1)==1
                if ~ismember(f{i},fields(d))
                    d.(f{i})=nan(1,n); %init as nan
                end
                d.(f{i})(inds)=source.(f{i}); %fill relevant as double
            else
                sz=size(source.(f{i}));
                disp(sprintf('skipped %s which is size [%d x %d]', f{i},sz(1),sz(2)));
            end
        case {'cell'}
            disp(sprintf('skipped %s which is a %s', f{i},class(source.(f{i}))))
        otherwise
            disp(sprintf('found %s which is a %s', f{i},class(source.(f{i}))))
            error('bad type')
    end
end