function niellLabReport
doBall=false;
doBox=true;

if doBall
    recs = {...
        {'mtrix5' %wall cue flip
            {
            'ly02' 
            'ly05' 
            'ly06' 
            'ly09'
            }
        }

        {'jarmusch'
            {
            'ly01' %grating (moved to mtrix6?)
            'ly03' %grating
            'ly04' %wall cue flip
            'ly08' %wall cue flip
            }
        }
    };

    tic
    cellfun(@(x) cellfun(@(y)plotCrossingTime(y,['\\' x{1}]),x{2}),recs);
    toc
end

if doBox
    recs = {...
        {'mtrix1'
            {
                { 'mouse' %drifiting dots single lickometer
                    {
                    'e1lt' 
                    'e2lt' 
                    'j7lt' 
                    'n5lt' 
                    'n8lt' 
                    }
                }
                { {'mouse' '0512'} %spatial freq
                    {
                    'c1ln' 
                    'c1lt' 
                    'c2lt' 
                    'c3ln' 
                    }
                }                
                { 'wehr' %audio
                    {
                    '3499' %hasn't run yet?
                    }
                }
            }
        }

        {'mtrix2'
            {
                { 'mouse' %drifting dots background
                    {
                    'e1rt' 
                    'e2rt'
                    'n5rn' 
                    'n5rt' 
                    }
                }
                { {'mouse' '0512'} %spatial freq
                    {
                    'c1rn' 
                    'c1rt' 
                    'c2rn' 
                    'c2rt' 
                    }
                }  
                { 'wehr' %audio
                    {
                    '3231' 
                    '3350' 
                    }
                }
            }
        }

        {'mtrix3'
            {
                { 'mouse' %abstract
                    {
                    'j10rt' 
                    'j6rt' 
                    'j7rt' 
                    'j8rt' 
                    }
                }
                { 'wehr' %audio
                    {
                    '3233' 
                    '3337' 
                    '3398'
                    }
                }   
            }
        }

        {'mtrix4'
            {
                { 'mouse' %tilt
                    {
                    'j10ln'
                    'j10lt'
                    'j8ln'
                    'j8lt'
                    }
                }
                { 'wehr' %audio
                    {
                    '3236'
                    '3397'
                    '3500'
                    }
                }      
            }
        }
    };


    selection.type = 'performance';
    selection.filter = 'all';
    selection.filterVal=[];
    selection.filterParam=[];

    tic
    cellfun(@(x) cellfun(@(y) cellfun(@(z) g(x{1},y{1},z), y{2}) ,x{2}) ,recs);
    toc
end
close all

    function g(box,d,subj)        
        selection.subjects = {subj};
        selection.titles = selection.subjects;
        close all
        if iscell(d)
            s=d{2};
            d=d{1};
        else
            s='';
        end
        f = analysisPlotter(selection,['\\' box '\Users\nlab\Desktop\' d 'Data' s '\CompiledTrialRecords\'],false);
        width = get(get(f,'Children'),'XLim');
        uploadFig(f,subj,width(2)/10,200);
    end

end