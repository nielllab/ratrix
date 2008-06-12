function station=setSoundOn(station,val)
    if islogical(val)
        station.soundOn=val;
    else
        error('val should be logical')
    end