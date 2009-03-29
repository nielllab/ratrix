function [bound source details]  = getCenter(RFe,subjectID)
% This function calculates the std of the receptive field, using the parameters on the object.
% The result is returned in std normalized units as fraction of screen

[data success]=getPhysRecords(fullfile(getDataSource(RFe),subjectID),{'dateRange',RFe.dateRange},{'analysis','stim'},RFe.centerParams{1})
if ~success
    error('bad phys load!')
else
    analysisdata=data.analysisdata;
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


