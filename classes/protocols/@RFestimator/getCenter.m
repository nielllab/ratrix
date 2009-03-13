function ctr = getCenter(RFe)
% This function calculates the center position of the receptive field, using the parameters on the object.
% The result is returned as a 2-element array [x y] in normalized units as fraction of screen

RFData=getNeuralAnalysis(getDataSource(RFe),'last','RFEstimate');
stimulus.fitRF.medianFilter=logical(ones(3));
stimulus.fitRF.alpha=.05;



sigSpots=getSignificantSTASpots(RFData.STA,sum(RFData.cumulativeSpikeCount),RFData.mean,RFData.contrast,stimulus.fitRF.medianFilter,stimulus.fitRF.alpha);
if ~length(union(unique(sigSpots),[0 1]))==2
    error('more than one RF spot!')
end




switch RFe.method
    case 'fitGaussian'
        %fit a guassian to the binary image -- conservative
        [sigEnvelope sigConservativeParams] =fitGaussianEnvelopeToImage(sigSpots,0.05,[],false,false);

        %use the conservative field to narrow a better seach of the STA
        [STAenvelope STAparams] =fitGaussianEnvelopeToImage(STA,0.05,sigEnvelope,false,false);
    otherwise
        error('unsupported method');
end

ctr=STAparams(1:2);

end % end function