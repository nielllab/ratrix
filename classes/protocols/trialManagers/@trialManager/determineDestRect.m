function destRect = determineDestRect(tm, window, station, metaPixelSize, stim, strategy)

if window>=0
    [scrWidth scrHeight]=Screen('WindowSize', window);
else
    scrWidth=getWidth(station);
    scrHeight=getHeight(station);
end

if ~isempty(strategy) && strcmp(strategy, 'expert')
    height = stim.height;
    width = stim.width;
else
    if metaPixelSize == 0
        scaleFactor = [scrHeight scrWidth]./[size(stim,1) size(stim,2)];
    elseif length(metaPixelSize)==2 && all(metaPixelSize)>0
        scaleFactor = metaPixelSize;
    elseif isempty(metaPixelSize)
        % empty only for 'reinforced' phases, in which case we dont care what destRect is, since it will get overriden anyways
        % during updateTrialState(tm)
        scaleFactor = [1 1];
    else
        error('bad metaPixelSize argument')
    end
    if any(scaleFactor.*[size(stim,1) size(stim,2)]>[scrHeight scrWidth])
        scaleFactor.*[size(stim,1) size(stim,2)]
        scaleFactor
        size(stim)
        [scrHeight scrWidth]
        error('metaPixelSize argument too big')
    end

    height = scaleFactor(1)*size(stim,1);
    width = scaleFactor(2)*size(stim,2);
end

if window>=0
    scrRect = Screen('Rect', window);
    scrLeft = scrRect(1); %am i retarted?  why isn't [scrLeft scrTop scrRight scrBottom]=Screen('Rect', window); working?  deal doesn't work
    scrTop = scrRect(2);
    scrRight = scrRect(3);
    scrBottom = scrRect(4);
    scrWidth= scrRight-scrLeft;
    scrHeight=scrBottom-scrTop;
else
    scrLeft = 0;
    scrTop = 0;
    scrRight = scrWidth;
    scrBottom = scrHeight;
end

destRect = round([(scrWidth/2)-(width/2) (scrHeight/2)-(height/2) (scrWidth/2)+(width/2) (scrHeight/2)+(height/2)]); %[left top right bottom]

end % end function