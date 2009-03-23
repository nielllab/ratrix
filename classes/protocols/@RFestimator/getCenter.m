function ctr = getCenter(RFe,subjectID)
% This function calculates the center position of the receptive field, using the parameters on the object.
% The result is returned as a 2-element array [x y] in normalized units as fraction of screen



RFData=getNeuralAnalysis(fullfile(getDataSource(RFe),subjectID),RFe.dateRange,RFe.centerParams{1});


switch RFe.centerParams{2}
    case 'fitGaussian'
        alpha=RFe.centerParams{3}{1}
        [STAenvelope STAparams] =fitGaussianEnvelopeToImage(RFData.cumulativeSTA,alpha,[],false,false);
    case 'fitGaussianSigEnvelope'

        alpha=RFe.centerParams{3}{1}
        medianFilter=RFe.centerParams{3}{2}
        %fit a guassian to the binary significance image -- conservative
        sigSpots=getSignificantSTASpots(RFData.cumulativeSTA,RFData.cumulativeSpikeCount,stimdata.stimulusDetails.meanLuminance,stimdata.stimulusDetails.std,medianFilter,alpha);
        if ~length(union(unique(sigSpots),[0 1]))==2
            error('more than one RF spot!')
        end
        [sigEnvelope sigConservativeParams] =fitGaussianEnvelopeToImage(sigSpots,alpha,[],false,false);

        %use the conservative field to narrow a better seach of the STA
        [STAenvelope STAparams] =fitGaussianEnvelopeToImage(RFData.cumulativeSTA,alpha,sigEnvelope,false,false);
    otherwise
        error('unsupported method');
end

ctr=STAparams(1:2);

end % end function