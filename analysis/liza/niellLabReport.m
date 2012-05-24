function niellLabReport
recs = {...
    {'mtrix5'
        {
        'ly02' %wall cue flip
        'ly05' %wall cue flip
        'ly06' %wall cue flip
        }
    }
    
    {'jarmusch'
        {
        'ly01' %grating
        'ly03' %grating
        'ly04' %wall cue flip
        }
    }
};

cellfun(@(x) cellfun(@(y)plotCrossingTime(y,['\\' x{1}]),x{2}),recs);