function niellLabReport(force)
addpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'bootstrap'));
setupEnvironment;
dbstop if error

if ~exist('force','var') || isempty(force)
    force = false;
end

%combineTiffs;

doBox    = true;
doBall   = true;
doPsycho = true;

if doPsycho
    path = '\\mtrix4\Users\nlab\Desktop\mouseData\CompiledTrialRecords\';
    simplePsycho('orientations','deg orientation difference',uint8(7  ),@(x)arrayfun(@(x)num2str(prec(2*x*180/pi,1)),x,'UniformOutput',false),false,path);
    simplePsycho('pixPerCyc'   ,'pixels per cycle'          ,uint8(6:8),@(x)arrayfun(@(x)num2str(prec(x         ,1)),x,'UniformOutput',false),true ,path);
    
    path = '\\mtrix1\Users\nlab\Desktop\mouseData0512\CompiledTrialRecords\';
    simplePsycho('pixPerCyc'   ,'pixels per cycle'          ,uint8(6:9),@(x)arrayfun(@(x)num2str(prec(x         ,1)),x,'UniformOutput',false),true ,path);
    simplePsycho('orientations','deg'                       ,uint8(  9),@(x)arrayfun(@(x)num2str(       x*180/pi   ),x,'UniformOutput',false),false,path);
    
    path = '\\mtrix2\Users\nlab\Desktop\mouseData0512\CompiledTrialRecords\';
    simplePsycho('pixPerCyc'   ,'pixels per cycle'          ,uint8(6:9),@(x)arrayfun(@(x)num2str(prec(x         ,1)),x,'UniformOutput',false),true ,path);
    simplePsycho('orientations','deg'                       ,uint8(  9),@(x)arrayfun(@(x)num2str(       x*180/pi   ),x,'UniformOutput',false),false,path);
    
    compileAudioMice;
end

    function out=prec(in,n)
        out = round(in*10^n)/10^n;
    end

if doBox
    recs = {...
        {'wehr-ratrix1'
            {
                 { 'wehr' %audio
                    {
                    '3513'
                    '3516'
                    '3350'
                    '3515'
                    '3499'
                    '3500'
                    }
                }
            }
        }        
    
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
%                    '3499' %current
%                    '3513' %current
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
                    'c4rn' %new
                    'c4rt' %new
                    'c5rn' %new
                    'c5rt' %new
                    }
                }  
                { 'wehr' %audio
                    {
                    '3231' 
 %                   '3350' %current
                    '3691' %?
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
                    '3233' %abandoned?
                    '3337' 
                    '3398' %abandoned?
%                    '3500' %current
%                    '3515' %current
                    '3694' %?
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
                    % '3500' %moved to mtrix3?
%                    '3516' %current
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

if doBall
    recs = {...
        {'mtrix5' %wall cue flip
            {
            'ly02' 
            'ly05' 
            'ly06' 
            'ly09'
            'ly14' %new
            'ly11' %new
            'jbw03' %new
            'gcam21rt'
            'gcam20tt'
            'gcam13ln'
            }
        }
        {'jarmusch'
            {
            % 'ly01' %grating (moved to mtrix6?)
            'ly03' %grating
            'ly04' %wall cue flip
            'ly08' %wall cue flip
            'ly12' %new
            'gcam13tt'
            'gcam17tt'
            % 'gcam18lt' %who dat?
            'wg4lt'
            'gcam19tt'
            }
        }
        {'mtrix6'
            {
            'ly01'
            'jbw01' %new
            'jbw02' %new
            'ly10' %new
            'ly13' %new
            'ly15'
            'jbw04'
            'wg2'
            'gcam17rn'
            'wg4rt'
            }
        }
        {'mtrix11'
            {
            'gcam28lt'
            'gcam30lt'
            }
        }      
        {'mtrix13'
            {
            'gcam25rt'
            'gcam30rn'
            }
        }        
% these guys are on non-imaging rigs right now        
%         {'lee'
%             {
%             'gcam13ln'
%             'gcam13tt'
%             }
%         }        
    };

    tic
    cellfun(@(x) cellfun(@(y)plotCrossingTime(y,['\\' x{1}],force),x{2}),recs);
    toc
end

close all

    function g(box,d,subj)        
        selection.subjects = {subj};
%         if strcmp(subj,'c1ln')
%             keyboard
%         end
        selection.titles = selection.subjects;
        close all
        if iscell(d)
            s=d{2};
            d=d{1};
        else
            s='';
        end
        f = analysisPlotter(selection,['\\' box '\Users\nlab\Desktop\' d 'Data' s '\CompiledTrialRecords\'],false);
        if ~isempty(f)
            width = get(get(f,'Children'),'XLim');
            uploadFig(f,subj,width(2)/10,200);
        end
    end

end