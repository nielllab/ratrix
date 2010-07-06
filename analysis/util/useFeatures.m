function [features nrDatapoints] = useFeatures(data,featureList,details)
% This function does feature calculation.
% INPUTS: data - a NxM matrix, where N is the number of spikes, and M is the number of sample points per spike
%         featureList - a list of features to calculate
%         details - contains information about how to calculate the features required
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
            score = (data-repmat(mean(data),[size(data,1) 1]))*details.tenPCs.pc;
            features=[features score(:,1:10)];
            nrDatapoints=nrDatapoints+10; %first 10 PCs            
        case {'wavePC1', 'wavePC2','wavePC123'}
            w=data;
            l2norms = sqrt(sum(w.^2,2)); % normalize waveforms first
            w = w./l2norms(:,ones(1,size(data,2)));
            switch feat
                case 'wavePC1'
                    score = w*details.wavePC1.pc;
                    features=[features score(:,1)]; % first PC only
                    nrDatapoints=nrDatapoints+1;
                    details.wavePC1.pc = pc(:,1);
                case 'wavePC2'
                    score = w*details.wavePC2.pc;
                    features=[features score(:,2)]; % 2nd PC only
                    nrDatapoints=nrDatapoints+1;
                    details.wavePC2.pc = pc(:,1:2);
                case 'wavePC123'
                    score = w*details.wavePC123.pc;
                    features=[features score(:,1:3)]; % first 3
                    nrDatapoints=nrDatapoints+3;
                    details.wavePC123.pc = pc(:,1:3);
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