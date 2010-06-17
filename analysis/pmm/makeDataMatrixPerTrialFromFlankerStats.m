function D=makeDataMatrixPerTrialFromFlankerStats(names,params,useConds,features)
%note this makes per trial data out of data organized per subject per
%condition.  no features can be accessed that were not already homogenous
%in the condition indices of the usedConds

if ~exist('features','var') || isempty(features)
    features={'subject','correct','condition'};
    %features={'subject','correct','condition','isoOri','isoAxis'}; anoa n
    %runs out of memory
end

%init
condIDs=find(ismember(names.conditions,useConds));
numTrials=params.raw.numAttempt(:,condIDs);
total=sum(numTrials(:));
numSubjects=length(names.subjects); 

for f=1:length(features)
    if strcmp('condition',features{f})
        %init as strings
        maxStrLength=max(cellfun(@length,names.conditions(condIDs)));
        D.(features{f})=char(zeros(total,maxStrLength));
    elseif strcmp('subjectLogicalMatrix',features{f})
        D.(features{f})=zeros(total,numSubjects);
    elseif strcmp('conditionLogicalMatrix',features{f})
        D.(features{f})=zeros(total,length(condIDs));  
    else % all otheres nan'd
        D.(features{f})=nan(total,1);
    end
end

cumTrials=cumsum(numTrials,2);
currentTrial=0;
for s=1:numSubjects
    for c=1:length(condIDs)
        n=params.raw.numAttempt(s,condIDs(c));
        for f=1:length(features)
            switch features{f}
                case 'subject'
                    D.(features{f})(currentTrial+1:currentTrial+n)=str2num(names.subjects{s});
                case 'correct'
                    nc=params.raw.numCorrect(s,condIDs(c));
                    D.(features{f})(currentTrial+1:currentTrial+n)=[ones(1,nc) zeros(1,n-nc)];
                case 'condition'
                    strLenth=length(names.conditions{condIDs(c)});
                    D.(features{f})(currentTrial+1:currentTrial+n,1:strLenth)=repmat(names.conditions{condIDs(c)},n,1);
                case 'isoOri'
                    iso=any(strcmp(names.conditions{condIDs(c)},{'colin','para'}));
                    D.(features{f})(currentTrial+1:currentTrial+n)=iso;
                case 'isoAxis'
                    iso=any(strcmp(names.conditions{condIDs(c)},{'colin','changeFlank'}));
                    D.(features{f})(currentTrial+1:currentTrial+n)=iso;
                case 'subjectMean'
                    mn=sum(params.raw.numCorrect(s,condIDs))/sum(params.raw.numAttempt(s,condIDs));
                    D.(features{f})(currentTrial+1:currentTrial+n)=mn;
                case 'subjectLogicalMatrix'
                    D.(features{f})(currentTrial+1:currentTrial+n,s)=1;
                case 'conditionLogicalMatrix'
                    D.(features{f})(currentTrial+1:currentTrial+n,c)=1;
                otherwise
                    features{f}
                    error('unknown feature')
            end
        end
        currentTrial=currentTrial+n;
    end
end

