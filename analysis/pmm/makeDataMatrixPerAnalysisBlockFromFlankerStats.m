function D=makeDataMatrixPerAnalysisBlockFromFlankerStats(names,params,useConds,features,blockLength,limitToMinBlocksPerSubjCond)
%note this makes per trial data out of data organized per subject per
%condition.  no features can be accessed that were not already homogenous
%in the condition indices of the usedConds


hasThirds=~isempty(strfind(params.settings.conditionType,'&thirds'));
hasTenths=~isempty(strfind(params.settings.conditionType,'&tenths'));
hasNFBLock=~isempty(strfind(params.settings.conditionType,'&nfBlock'));

if ~exist('features','var') || isempty(features)
    %features={'subject','correct','condition'};
    features={'subject','correct','condition','isoOri','isoAxis'};
end

if ~exist('blockLength','var') || isempty(blockLength)
    blockLength=100;
elseif hasThirds || hasTenths
    error('cant define block length if using conditions already split into blocks')
end

if ~exist('limitToMinBlocksPerSubjCond','var') || isempty(limitToMinBlocksPerSubjCond)
    limitToMinBlocksPerSubjCond=false;
    %allows there to be a fixed number of blocks per subject
    %... throws out lots of data!
end

%init
condIDs=find(ismember(names.conditions,useConds));

if hasThirds || hasTenths
    if hasNFBLock
        error('noflank block is not interleaved and will cause time problems')
    end
    
    if hasThirds
        blocksPerSubjCond=3*ones(length(names.subjects),length(condIDs));
    elseif hasTenths
        blocksPerSubjCond=10*ones(length(names.subjects),length(condIDs));
    elseif hasTenths && hasThirds
        error('should never happen')
    end
    
    if limitToMinBlocksPerSubjCond
        error('not implimented in this mode')
    end
else
    blocksPerSubjCond=floor(params.raw.numAttempt(:,condIDs)/blockLength);
    if limitToMinBlocksPerSubjCond
        minBlocks=min(blocksPerSubjCond(:));
        numLeftover=minBlocks*length(names.subjects)*length(condIDs);
        fractionRemoved=1-(numLeftover/sum(blocksPerSubjCond(:)));
        warning(sprintf('throwing out %2.2f%% of data to even out blocks',100*fractionRemoved))
        blocksPerSubjCond(:)=minBlocks;
    end
end
total=sum(blocksPerSubjCond(:));

for f=1:length(features)
    if strcmp('condition',features{f})
        %init as strings
        maxStrLength=max(cellfun(@length,names.conditions(condIDs)));
        D.(features{f})=char(zeros(total,maxStrLength));
    else % all otheres nan'd
        D.(features{f})=nan(total,1);
    end
end

currentBlock=0;
for s=1:length(names.subjects)
    for c=1:length(condIDs)

        numBlocks=blocksPerSubjCond(s,c); 

        if hasThirds || hasTenths
            for b=1:numBlocks
                
            end
        else
            if ismember('dprime',features)
                % do hit fa stuff
                numHit=params.raw.numHits(s,condIDs(c));
                numMiss=params.raw.numMisses(s,condIDs(c));
                numCRs=params.raw.numCRs(s,condIDs(c));
                numFAs=params.raw.numFAs(s,condIDs(c));
                numSig=numHit+numMiss;
                numNoSig=numCRs+numFAs;
                sig=[ones(1,numSig) zeros(1,numNoSig)];
                correct=[ones(1,numHit) zeros(1,numMiss) ones(1,numCRs) zeros(1,numFAs)];
                n=params.raw.numAttempt(s,condIDs(c));
                reorder=randperm(n);
                correct=correct(reorder);
                sig=sig(reorder);
            else
                %simpler
                n=params.raw.numAttempt(s,condIDs(c));
                nc=params.raw.numCorrect(s,condIDs(c));
                correct=[ones(1,nc) zeros(1,n-nc)];
                reorder=randperm(n);
                correct=correct(reorder);
            end
        end
        for b=1:numBlocks
            currentBlock=currentBlock+1;
            whichInBlock=1+(b-1)*blockLength:b*blockLength; % not for time based
            for f=1:length(features)
                switch features{f}
                    case 'subject'
                        D.(features{f})(currentBlock)=str2num(names.subjects{s});
                    case 'subjectID'
                        D.(features{f})(currentBlock)=s;
                    case 'correct'
                        if hasThirds || hasTenths
                            baseName=names.conditions{condIDs(c)}(1:end-3);  % chop off the '-b1'
                            thisC= find(strcmp(names.conditions,[baseName '-b' num2str(b)]));
                            attempt=params.raw.numAttempt(s,thisC);
                            cor=params.raw.numCorrect(s,thisC);
                            D.(features{f})(currentBlock)=cor/attempt;
                        else
                            D.(features{f})(currentBlock)=mean(correct(whichInBlock));
                        end     
                    case 'dprime'
                        if hasThirds || hasTenths
                            cor=100
                            sg=100
                            error('not yet')
                        else
                            cor=correct(whichInBlock);
                            sg=sig(whichInBlock);
                        end

                        pad=1; % 1 = agrestiACffo
                        h=sum(cor(sg==1))+pad;
                        m=sum(~cor(sg==1))+pad;  
                        fa=sum(~cor(sg==0))+pad;    
                        cr=sum(cor(sg==0))+pad;     
                        dpr = sqrt(2) * (erfinv((h-m)/(h+m)) + erfinv((cr - fa)/(cr+fa)));
                        D.(features{f})(currentBlock)=dpr;
                    case 'condition'
                        if hasThirds || hasTenths
                            endID=strfind(names.conditions{condIDs(c)},'-b');  % chop off the '-b1'
                            D.(features{f})(currentBlock,1:endID-1)=names.conditions{condIDs(c)}(1:endID-1);
                        else
                            strLenth=length(names.conditions{condIDs(c)});
                            D.(features{f})(currentBlock,1:strLenth)=names.conditions{condIDs(c)};
                        end
                    case 'block'
                         D.(features{f})(currentBlock)=b;
                    case 'conditionID'
                        D.(features{f})(currentBlock)=c;
                    case 'isoOri'
                        iso=any(strcmp(names.conditions{condIDs(c)},{'colin','para'}));
                        D.(features{f})(currentBlock)=iso;
                    case 'isoAxis'
                        iso=any(strcmp(names.conditions{condIDs(c)},{'colin','changeFlank'}));
                        D.(features{f})(currentBlock)=iso;
                    otherwise
                        error('unknown feature')
                end
            end
        end
        
    end
end