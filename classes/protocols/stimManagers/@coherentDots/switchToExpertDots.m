function d=switchToExpertDots(d)

background.contrastFactor = 0;
background.sizeFactor = 0;
background.densityFactor = 0;
d = setBackground(d,background);

d.movie_duration = inf;
d.replayMode = 'expert';

d.screen_width = getMaxWidth(d.stimManager);
d.screen_height = getMaxHeight(d.stimManager);

d.stimManager = setScaleFactor(d.stimManager,ones(1,2));
end