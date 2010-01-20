function [d type]=addYesResponse(d,r,forceGotoSideToBeDetection)
%adds a column of yes=1, no=0 and undefined=nan
%type is 'rightMeansYes' or 'leftMeansYes'


if ~exist('r','var') 
    r=[];
end

if ~exist('forceGotoSideToBeDetection','var') 
    forceGotoSideToBeDetection=false;
end



if size(d.date,2)>0
    f=fields(d);
    if ~all(ismember({'correctResponseIsLeft','response','correct'},f))
        error('missing one of the required fields: ''correctResponseIsLeft'',''response'',''correct'' ')
    end

    contrasts=unique(d.targetContrast(~isnan(d.targetContrast)));
    if ~any(contrasts==0)
        if forceGotoSideToBeDetection
            %all target contrasts with correct response is left==1, will be set to 0
            %will become 'rightMeansYes'
            d.targetContrast(d.correctResponseIsLeft==1)=0;
            warndlg('mapping goToSide onto detection via ''rightMeansYes''')
        else
            contrasts
            error('this analysis only makes sense for detection which requres target to equal 0 contrast sometimes')
            %if there are very few trials then it IS possible to accidentally trip this error
            %return
        end
    end

    
    cutOut=zeros(size(d.date)); %don't cut anything out, unless known prob for specific rat
    %confirm its detection and the type of response that means yes
    if all(d.correctResponseIsLeft(d.targetContrast==0)==1) & all(d.correctResponseIsLeft(d.targetContrast>0)==-1)
        type='rightMeansYes';
    elseif all(d.correctResponseIsLeft(d.targetContrast==0)==-1) & all(d.correctResponseIsLeft(d.targetContrast>0)==1)
        type='leftMeansYes';
    else

        warning('some rats like 138 and 139 had contrast sweeps with 0 included- don''t analyze those trials without good reason')
        %quick and dirty code to find when and what
        zeroContrastWrongLeftRuleFraction=sum(d.correctResponseIsLeft(d.targetContrast==0)==1)./sum(d.targetContrast==0)
        zeroContrastWrongRightRuleFraction=sum(d.correctResponseIsLeft(d.targetContrast==0)==-1)./sum(d.targetContrast==0)
        BadLeft=find(d.correctResponseIsLeft(d.targetContrast==0)==1); %actually all of them...index the first one
        BadRight=find(d.correctResponseIsLeft(d.targetContrast==0)==-1);
        zeroContrastWrongRuleFraction=min(zeroContrastWrongLeftRuleFraction,zeroContrastWrongRightRuleFraction) % guess
        whichRule=find([zeroContrastWrongLeftRuleFraction,zeroContrastWrongRightRuleFraction]==zeroContrastWrongRuleFraction)
        switch whichRule
            case 1 
                error('never yet')
            case 2
                firstBadTrial=d.trialNumber( BadRight(1) )
                lastBadTrial=d.trialNumber(BadRight(end) )
                firstBadTrialDate=datestr(d.date(BadRight(1) ))
                lastBadTrialDate=datestr(d.date(BadRight(end) ))
        end
        %d=getSmalls(char(d.info.subject));%,[datenum(firstBadTrialDate)-10 datenum(firstBadTrialDate)+10]);  % inifinite recursion!
        %figure; doPlotPercentCorrect(d)
        
            switch char(d.info.subject)
                case {'138','139'}
                    type='rightMeansYes';
                    if ~special138_139data(d)
                        cutOut(firstBadTrial:lastBadTrial)=1; % when processing the later data on these rats, dont't define yes in the bad data
                    else
                        %special data gets analyzed anyways, if its ONLY
                        %that data... "yes" data really does reflect true
                        %yes responses, though there may be confusion with
                        %the correct response with no contrast if doing
                        %subsequent error checking
                    end 
                case {'228'}
                    type='leftMeansYes';
                    apparentRuleSwitchWithCued=strcmp(d.info.strLUT(d.trialManagerClass),'cuedGoNoGo');
                    cutOut(apparentRuleSwitchWithCued)=1; % removing these for now, cuz its easy... thinking needed to keep apparant conflicting rule
                    if any(d.date(~cutOut)>pmmEvent('228-first-cuedGoNoGo'))        
                        error('no stuff after cued date is expected to be in right now')
                    end
                otherwise
                    error('should never happen-- suggests this rat has some trials where yes=left and others where yes=right')
            end
       
    end

    if  ~isempty(r)
        %extra check performed if the ratrix is passed in
        facts=getBasicFacts(r);
        index=find(strcmp(d.info.subject,facts(:,1)));
        protocolName=facts{index,8};
        ratrixSaysRight=~isempty(strfind(lower(protocolName),'right'));
        ratrixSaysLeft=~isempty(strfind(lower(protocolName),'left'));
        if ratrixSaysRight==ratrixSaysLeft
            ratrixSaysRight
            ratrixSaysLeft
            error('only one must be true, and they must be different')
        end

        if ratrixSaysRight & strcmp(type,'rightMeansYes')
            %okay
        elseif ratrixSaysLeft & strcmp(type,'leftMeansYes')
            %also cool
        else
            error('this ratrix does not agree with calculated yes meaning')
        end
    end

    d.yes=nan(1,length(d.date));
    possible=~isnan(d.targetContrast) & ~cutOut; % target contrast is use to determine if it was a flankerProtocol with a target, (vs. free drinks or other stim Managers)
    switch type
        case 'rightMeansYes'
            d.yes(possible & d.response==3)=1;
            d.yes(possible & d.response==1)=0;
        case 'leftMeansYes'
            d.yes(possible & d.response==1)=1;
            d.yes(possible & d.response==3)=0;
        otherwise
            error('bad type')
    end
    
    d.correctAnswerID=d.correctResponseIsLeft;
    d.correctAnswerID(d.correctAnswerID==-1)=3; % map "not left" to right port=3
    if ~all(ismember(d.correctAnswerID(~isnan(d.correctAnswerID)),[1 3]))
        unique(d.correctAnswerID)
        error('unexpected answer IDs')
    end
    
else
    d.yes=[];
    type='unknown';
end