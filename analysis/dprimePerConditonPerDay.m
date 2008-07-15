function [dpr more]=dprimePerConditonPerDay(trialsCompletedBy,conditionInds,goods,smallData);

verbose=0;

trialsCompletedBefore=[1 trialsCompletedBy];
days=size(trialsCompletedBy,2);
conditions=size(conditionInds,1);
dpr=zeros(conditions,days);

%reconstructs the keypress that would be correct (could return this directly)
%this is used by the dprime calulation
smallData.correctAnswerID=(smallData.correctResponseIsLeft);
smallData.correctAnswerID(smallData.correctAnswerID==-1)=3;


for day=1:days
    trialRange=zeros(size(goods));  %restrict noSigTrials to the same time range (assume one continuous block- is that true?)
    trialRange(trialsCompletedBefore(day):trialsCompletedBefore(day+1))=1;
    for c=1:conditions
        
        %select indices
        which=trialRange & conditionInds(c,:);
        
        %choose trials with no signal
        whichNoSig=trialRange & conditionInds(c,:) & (smallData.correctResponseIsLeft==1);

        restrictSampleOfNoSig=0;   %if =0 then dprime will sample more (accoss "what contrast would have been") to get a better estimate of the no signal case
        if restrictSampleOfNoSig
            totalCandidates=sum(whichNoSig);
            whichNoSig=whichNoSig & aSubSampling
        else
            %use everything in the timeRange
            if verbose
                disp(' ')
                disp(sprintf('day: %3.3g condition: %d', day,c))
                disp(sprintf('correct rejection and false alarms are sampled %2.2g times more frequently ',sum(whichNoSig)/sum(which)))
            end
        end

        %for percent correct - not used
          %numCorrect(i,j) =sum(smallData.correct(which));
          %numAttempted(i,j)=sum(which);

        %d-prime
        if verbose
            flag='nothing';
        else
            flag='silent';
        end

        if sum(which | whichNoSig)>0
            %do analysis
             [dpr(c,day) anal]=dprime(smallData.response(which | whichNoSig),smallData.correctAnswerID(which | whichNoSig),flag);
             more{c,day}=anal;
        else
            disp(sprintf('day %d, condition %d -- no responses',day,c))
            beep
            dpr(c,day)=-99;
            more{c,day}=[];
        end
        
            
    end
end