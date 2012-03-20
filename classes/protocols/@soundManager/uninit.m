function sm=uninit(sm,station)
if isa(station,'station')
    sm=decache(sm);
    
    if getSoundOn(station)
        %can't put in soundManager.decache() directly, because need to be able to call decache without closing psychportaudio + losing buffers
        initPPA;
        PsychPortAudio('Close'); %does this work OK if sounds currently playing?  yes on osx...
        clear PsychPortAudio;
    end
else
    error('need a station')
end
end

function initPPA
if ismac
    fn='libportaudio.0.0.19.dylib';
    paths={'/usr/local/lib','/usr/lib','~/lib'};
    src=fullfile(PsychtoolboxRoot,'PsychSound',fn);
    
    if ~any(cellfun(@(x) exist(fullfile(x,fn),'file'),paths))
        if exist(src,'file')
            good=false;
            for i=1:length(paths)
                if ~exist(paths{i},'dir')
                    [a b c]=mkdir(paths{i});
                    
                    if a~=1
                        b
                        c
                        warning('couldn''t mkdir')
                    end
                end
                
                [a b c]=copyfile(src,fullfile(paths{i},fn)); %not fullfiling like this might be why we sometimes make files when we think we're making dirs
                if a~=1
                    b
                    c
                    warning('couldn''t copy libportaudio')
                else
                    good=true;
                    break
                end
            end
            if ~good
                error('couldn''t copy libportaudio')
            end
        else
            error('can''t find libportaudio, maybe need updatepsychtoolbox')
        end
    end
end
InitializePsychSound(1);
end