function sm=addSound(sm,clip)

soundName = getName(clip);
done = 0;
for i=1:length(sm.clips)
    if strcmp(getName(sm.clips{i}),soundName)
        if done
            error('found that name twice')
        else
            % Found the same name, update it
            done = 1;
            sm.clips{i}=clip;
        end
    end
end
if ~done
    % Name not found, add it to the end
    sm.clips = [sm.clips {clip}];
end