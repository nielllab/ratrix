function [bound source details]  = getCenter(RFe,subjectID,trialRecords)
% This function calculates the std of the receptive field, using the parameters on the object.
% The result is returned in std normalized units as fraction of screen


details=[];
switch RFe.centerParams{1}
    case 'spatialWhiteNoise'
        
        
        [data success]=getPhysRecords(fullfile(getDataSource(RFe),subjectID),{'dateRange',RFe.dateRange},{'analysis','stim'},RFe.centerParams{1})
        if ~success
            error('bad phys load!')
        else
            analysisdata=data.cumulativedata;
            stimulusDetails=data.stimulusDetails;
        end
        
        % for record keeping
        source.subjectID=subjectID;
        source.trialNum=data.trialNum;
        source.timestamp=data.timestamp;
        
        % find brightest point, to select time frame of interest
        ind=find(max(analysisdata.cumulativeSTA(:))==analysisdata.cumulativeSTA(:));
        [x y t]=ind2sub(size(analysisdata.cumulativeSTA),ind);
        STA2d=analysisdata.cumulativeSTA(:,:,t);
        
        switch RFe.centerParams{2}
            case 'fitGaussian'
                stdThresh=RFe.centerParams{3}{1};
                [STAenvelope STAparams] =fitGaussianEnvelopeToImage(STA2d,stdThresh,false,false,false);
                
                if nargout>2
                    details.STAparams=STAparams;
                    details.STAenvelope=STAenvelope;
                    details.STA2d=STA2d;
                end
                
                bound=[STAparams(5)];  % only one parameter = radial std
            otherwise
                error('currently unsupported method');
        end
        
    case 'gratingWithChangeableAnnulusCenter'
        switch RFe.centerParams{2}
            case 'lastDynamicSettings'
                %this does not need a phys analysis, rather it needs
                %details of the dymanimic settings in the trialRecords!
                
                %trialRecords.stimManagerClass
                %cands=find(strcmp({trialRecords.stimManagerClass},'gratings'))
                %this only finds the gratings candidates from THIS session,
                %so instead we look for a signature field of gratingWithChangeableAnnulusCenter
                
                bound=[];
                for i=length(trialRecords):-1:1  % go backwards through the trial records until changeableAnnulusCenter is found and true
                    if isfield(trialRecords(i).stimDetails,'changeableAnnulusCenter') && trialRecords(i).stimDetails.changeableAnnulusCenter==1
                        useTrial=i; % the most recent trial with changeableAnnulusCenter
                        
                        whichPhase=1;  % could have a smarter way of doing this by finding it... autopilot uses 1
                        annulusInd=trialRecords(useTrial).phaseRecords(whichPhase).dynamicDetails{end}.annulusInd;
                        
                        bound=trialRecords(useTrial).stimDetails.annuli(annulusInd);
                        
                        source.subjectID=trialRecords(useTrial).subjectsInBox;
                        source.trialNum=trialRecords(useTrial).trialNumber;
                        source.timestamp=trialRecords(useTrial).date;
                        
                        break
                    end
                end
                
                if isempty(bound)
                    numTrailsChecked=length(trialRecords)
                    error('there are no trials with gratings in the trial history!')
                end
                
        end
    otherwise
        RFe.centerParams{2}
        error('bad source')
end
