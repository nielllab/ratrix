function ctr = getCenter(RFe,subjectID)
% This function calculates the center position of the receptive field, using the parameters on the object.
% The result is returned as a 2-element array [x y] in normalized units as fraction of screen


%sca
%keyboard
RFData=getNeuralAnalysis(fullfile(getDataSource(RFe),subjectID),RFe.dateRange,RFe.centerParams{1});
%load('\\132.239.158.179\datanet_storage\demo1\analysis\physAnalysis_191-20090205T151316.mat')
load('\\132.239.158.179\datanet_storage\demo1\analysis\334-20090206T164500\physAnalysis_334-20090206T164500.mat')


% find brightest point, to select time frame of interest
ind=find(max(analysisdata.cumulativeSTA(:))==analysisdata.cumulativeSTA(:));
[x y t]=ind2sub(size(analysisdata.cumulativeSTA),ind);
STA2d=analysisdata.cumulativeSTA(:,:,t);
        
switch RFe.centerParams{2}
    case 'fitGaussian'
        alpha=RFe.centerParams{3}{1}
        
        [STAenvelope STAparams] =fitGaussianEnvelopeToImage(STA2d,alpha,[],false,false);
    case 'fitGaussianSigEnvelope'

        alpha=RFe.centerParams{3}{1}
        medianFilter=RFe.centerParams{3}{2}
        %fit a guassian to the binary significance image -- conservative
        sigSpots=getSignificantSTASpots(STA2d,RFData.cumulativeSpikeCount,stimdata.stimulusDetails.meanLuminance,stimdata.stimulusDetails.std,medianFilter,alpha);
        if ~length(union(unique(sigSpots),[0 1]))==2
            error('more than one RF spot!')
        end
        [sigEnvelope sigConservativeParams] =fitGaussianEnvelopeToImage(sigSpots,alpha,[],false,false);

        %use the conservative field to narrow a better seach of the STA
        [STAenvelope STAparams] =fitGaussianEnvelopeToImage(STA2d,alpha,sigEnvelope,false,false);
    otherwise
        error('unsupported method');
end
 % note param convention and matrix convention: (x(1) y(1))/ [x is size 2, y is size 1]
ctr=STAparams(1:2)./[size(STA2d,2) size(STA2d,1)];

if any(ctr>1) || any(ctr<0)
    warning('center is estimated to be off screen')
    beep; beep
    %force on screen
    ctr(ctr>1)=1;
    ctr(ctr<0)=0;
end


end % end function