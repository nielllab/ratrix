function compileAudioMice
addpath(fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))),'bootstrap'));
setupEnvironment;
dbstop if error

if ~ispc
    error('haven''t xplatformed yet')
end

ctrPath = '\\reichardt\figures\audio\';

    recs = {...
        {'mtrix1'
            {
             '3499'
             %'3513' %new
            }
        }

        {'mtrix2'
            {
             '3231' 
             '3350' 
            }
        }

        {'mtrix3'
            {
             %'3233' %abandoned?
             '3337' 
             %'3398' %abandoned?
             '3500'
             %'3515' %new
            }
        }

        {'mtrix4'
            {
             '3236'
             '3397'
             %'3500' %moved to mtrix3
             %'3516' %new
            }
        }
    };

cellfun(@(x)compile(x{:},ctrPath),recs);

simplePsycho('amp','amp',uint8(5:6),@(x)arrayfun(@(x)[num2str(prec(100*x,1)) '%'],x,'UniformOutput',false),true,ctrPath);
end

function compile(srv,subs,ctrPath)
perm = ['\\' srv '\Users\nlab\Desktop\wehrData\PermanentTrialRecordStore'];

done = dir(ctrPath);
done = {done.name};

d = dir(fullfile(perm,'..','CompiledTrialRecords','*.compiledTrialRecords.*.mat'));
d = {d(any(cell2mat(cellfun(@cell2mat,...
                            cellfun(@(x)cellfun(@(y)~isempty(y),...
                                                strfind({d.name},x),...
                                                'UniformOutput',false),...
                                    subs,...
                                    'UniformOutput',false),...
                            'UniformOutput',false)...
                    ),...
           1)...
      ).name};

subs = strtok(d(~ismember(d,done)),'.');
if ~isempty(subs)
    compileDetailedRecords([],subs,[],perm,ctrPath); %make incremental?
end
end

function out=prec(in,n)
out = round(in*10^n)/10^n;
end