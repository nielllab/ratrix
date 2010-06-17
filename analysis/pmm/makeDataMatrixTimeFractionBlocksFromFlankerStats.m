function  D=makeDataMatrixTimeFractionBlocksFromFlankerStats(names,params,useConds,features,fraction)

for s=1:length(names.subjects)
    
    if ~isempty(strfind(params.settings.conditionType,'&nfBlock'))
        error('noflank block is not interleaved and will cause time problems')
    end
      
    if ~isempty(strfind(params.settings.conditionType,'&thirds')) && isempty(strfind(params.settings.conditionType,'&tenths'))
        error('must have prerun tenths or thirds to use time splitting')
    end
    
    %THIS ALREADY HAPPENED and now we can trust the JOINT NAMES to get
    %access to the fraction splitting
    %
    %d=getSmalls(names.subjects{s},params.settings.dateRange,[], false);
    %d=filterFlankerData(d,params.settings.filterType);
    %goods=getGoods(d,params.settings.goodTrialType);
    %condInds=getFlankerConditionInds(d,goods,params.settings.conditionType);
    numFractio

    for c=1:length(useConds)
        for fr=1:size(fractionCondInds,1) % or 2?
            which=fractionCondInds(fr,:) & condInds(useConds(c),:);
            
            for f=1:length(features)
                switch features{f}
                    case 'subject'
                        D.(features{f})(end+1)=str2num(names.subjects{s});
                    case 'correct'  % hit miss 
                        D.(features{f})(end+1)=mean(d.correct(which))
                        
                    case 'condition'
                        strLenth=length(names.conditions{condIDs(c)});
                        D.(features{f})(end+1,1:strLenth)=names.conditions{condIDs(c)};
                    %case 'isoOri'
                        %iso=any(strcmp(names.conditions{condIDs(c)},{'colin','para'}));
                        %D.(features{f})(currentTrial+1:currentTrial+n)=iso;
                    %case 'isoAxis'
                        %iso=any(strcmp(names.conditions{condIDs(c)},{'colin','changeFlank'}));
                        %D.(features{f})(currentTrial+1:currentTrial+n)=iso;
                    %case 'subjectMean'
                        %mn=sum(params.raw.numCorrect(s,condIDs))/sum(params.raw.numAttempt(s,condIDs));
                        %D.(features{f})(currentTrial+1:currentTrial+n)=mn;
                    %case 'subjectLogicalMatrix'
                        %D.(features{f})(currentTrial+1:currentTrial+n,s)=1;
                    %case 'conditionLogicalMatrix'
                        %D.(features{f})(currentTrial+1:currentTrial+n,c)=1;
                    otherwise
                        features{f}
                        error('unknown feature')
                end
            end
            
        end
    end
end