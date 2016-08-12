%%% flip map to correct for inverted monitors
%%% effectively performs a time-reversal by taking complex conjugate of fourier map
%%% saves flipped map back into map file, along with a flag, so subsequent
%%% analysis doesn't need to worry about it

clear all
[f p] = uigetfile('*.mat','map file');
load(fullfile(p,f),'map','mapNorm','mapflipped');

figure
imshow(polarMap(map{3}))

if input('flip map? 0/1 : ');
    for i = 1:3
        map{i} = conj(map{i});
        mapNorm{i} = conj(mapNorm{i});
    end
    if exist('mapflipped','var')
        mapflipped = 1-mapflipped;
    else
        mapflipped = 1;
    end
    figure
    imshow(polarMap(map{3}))
    if input('save new map? 0/1 : ');
        save(fullfile(p,f),'map','mapNorm','mapflipped','-append');
    end
end
