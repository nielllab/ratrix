function [features nrDatapoints] = calculateFeatures(data,featureList)
% This function does feature calculation.
% INPUTS: data - a NxM matrix, where N is the number of spikes, and M is the number of sample points per spike
%         featureList - a list of features to calculate
% OUTPUTS: featureData - a NxF matrix, where N is the number of spikes, and F is the total number of feature datapoints
%          nrDatapoints - the number of feature datapoints F

features=[];
nrDatapoints=0;

for fInd=1:length(featureList)
    feat=featureList{fInd};
    switch feat %change to allow more than one feature
        case 'allRaw'
            nrDatapoints=size(data,2);
            features=[features data];
        case 'tenPCs'
            [pc,score,latent,tsquare] = princomp(data);
            nrDatapoints=nrDatapoints+10; %first 10 PCs
            features=[features score(:,1:10)];
        case {'wavePC1', 'wavePC2','wavePC123'}
            w=data;
            l2norms = sqrt(sum(w.^2,2)); % normalize waveforms first
            w = w./l2norms(:,ones(1,size(data,2)));
            [pc,score] = princomp(w);
            switch feat
                case 'wavePC1'
                    features=[features score(:,1)]; % first PC only
                    nrDatapoints=nrDatapoints+1;
                case 'wavePC2'
                    features=[features score(:,2)]; % 2nd PC only
                    nrDatapoints=nrDatapoints+1;
                case 'wavePC123'
                    features=[features score(:,1:3)]; % first 3
                    nrDatapoints=nrDatapoints+3;
            end
        case 'energy'
            score=sqrt(sum(data(:,:).^2,2))./sqrt(size(data,2));
            nrDatapoints=nrDatapoints+1;
            features=[features score];
        case 'peak'
            score=max(data,[],2);
            nrDatapoints=nrDatapoints+1;
            features=[features score];
        case 'valley'
            score=min(data,[],2);
            nrDatapoints=nrDatapoints+1;
            features=[features score];
        case 'peakToValley'
            score=abs(max(data,[],2))./abs(min(data,[],2));
            nrDatapoints=nrDatapoints+1;
            features=[features score];
        case 'spikeWidth'
            [score imax] = max(data,[],2);
            [score imin] = min(data,[],2);
            score=abs(imin-imax);
            nrDatapoints=nrDatapoints+1;
            features=[features score];
        case 'waveFFT'
            Y = fft(squeeze(data(:,:))',size(data,2));
            Pyy = Y.*conj(Y)/size(data,2);
            WeightMatrix = repmat(([1:size(data,2)/2 size(data,2)/2:-1:1])',1,length(Pyy(1,:)));
            SumPyy = sum(Pyy);
            score = (sum(Pyy.*WeightMatrix)./SumPyy)';
            nrDatapoints=nrDatapoints+1;
            features=[features score];
        otherwise
            feat
            class(feat)
            error('unsupported feature selection');
    end
end

end % end function