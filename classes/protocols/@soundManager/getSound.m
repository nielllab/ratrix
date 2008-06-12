function [clip sampleRate sm updateSMCache] = getSound(sm,soundName)
    done=0;
    updateSMCache=0;
    for i=1:length(sm.clips)
        if strcmp(getName(sm.clips{i}),soundName)
            if done
                error('found that name twice')
            else
                done=1;
                [clip sampleRate newSC updateSC]=getClip(sm.clips{i});
                if updateSC
                    updateSMCache=1;
                    sm.clips{i}=newSC;
                end
            end
        end
    end
    if ~done
        error('no sound by that name')
    end