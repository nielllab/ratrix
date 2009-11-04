function [frames,origPulses,stimBreaks]=scanTriple(file,frameChan,stimChan,phaseChan,pulseTimes,indexChan)
frames=[];
stims=[];
phases=[];
stimBreaks=[];

stimsDone=false;
phasesDone=false;
stimBreaksDone=false;

% the (now obsolete) 'triple' protocol is as follows:
%frames - hi during calc, lo while waiting for flip (need to verify this -- we'll call the frame at the lo-hi transition)
%stims - hi during stim phases (we'll require hi throughout)
%phases - just lo-hi-lo pulses at phase boundaries (we'll require none throughout)

% the (newer and better) 'index' protocol adds one more to the above:
%index - hi-lo pulse at repeat boundaries (only in newer files)

% example triple file: '/Volumes/Maxtor One Touch II/eflister phys/physDB/164/04.07.09/891c8c7f8286129461df5aa06b799ead54d28176/pulse.891c8c7f8286129461df5aa06b799ead54d28176.txt'
%
% %CHANNEL%       %2%
% %Evt+-%
% %%
% %frames%
%
% %LOW%
% 0.0075696
% 0.0124500
% 0.0175711
% ...
% 0.0225511
%
% 4463.4590450
%
% %CHANNEL%       %3%
% %Evt+-%
% %No comment%
% %stim%
%
% %HIGH%
% 198.5272435
% 216.6404248
% 224.1121844
% 233.7317350
% 2270.7283673
% 3013.3481419
%
% %CHANNEL%       %4%
% %Evt+-%
% %No comment%
% %phase%
%
% %LOW%
% 210.9727200
% 210.9738820
% 216.6391466
% 216.6399766
% 229.9846336
% 229.9854885
% 233.7304568



%%%%%%%%%%%%%%%%%%

% example index file: '/Volumes/Maxtor One Touch II/eflister phys/physDB/164/04.15.09/8d2b23279f87853a7c63e4ab0ed38b8b150c317d/pulse.8d2b23279f87853a7c63e4ab0ed38b8b150c317d.txt'
%
% %CHANNEL%       %2%
% %Evt+-%
% %%
% %frames%
% 
% %LOW%
% 2614.0148484
% 2614.0171973
% 2614.0249827
% 2614.0272237
% 2614.0349178
% 2614.0372252
% ...
% 481.8410111
% 3481.8466966
% 3481.8509130
% 3481.8567562
% 3481.8610556
% 
% %CHANNEL%       %3%
% %Evt+-%
% %No comment%
% %stim%
% 
% %HIGH%
% 3169.5682436
% 3182.5958987
% 
% %CHANNEL%       %4%
% %Evt+-%
% %No comment%
% %phase%
% 
% %LOW%
% 3179.5796953
% 3179.5806913
% 3182.5943300
% 3182.5953011
% 
% %CHANNEL%       %5%
% %Evt+-%
% %No comment%
% %index%
% 
% %LOW%
% 2637.0082554
% 2637.0182735
% 2662.0248040
% 2662.0348138
% 2687.0414854
% 2687.0512877
% 2712.0476092
% 2712.0577518
% 2737.0642076
% 2737.0741676
% 2762.0806317
% 2762.0904589
% 2787.0969645
% 2787.1069494
% 2812.1134467
% 2812.1234399
% 2837.1298957
% 2837.1399885
% 2862.1363183
% 2862.1466850
% 2912.1692080
% 2912.1791099
% 2937.1857068
% 2937.1956087
% 2962.2020811
% 2962.2120079
% 2987.2185052
% 2987.2286229
% 3012.2249610
% 3012.2350372
% 3037.2414266
% 3037.2514613
% 3062.2580416
% 3062.2677692
% 3087.2744491
% 3087.2842348
% 3112.2907736
% 3112.3006838
% 3137.3071562
% 3137.3172739
% 3162.3138444
% 3162.3237380
% 3182.5975836
% 3182.6143413
% 3212.6126578
% 3212.6225929
% 3242.6324049
% 3242.6423649
% 3272.6522931
% 3272.6622282
% 3302.6718825
% 3302.6817180
% 3332.6816032
% 3332.6914221
% 3362.7012341
% 3362.7111526
% 3392.7208899
% 3392.7309578
% 3422.7406619
% 3422.7505638
% 3452.7502664
% 3452.7603509

parityFlip=false;
    function matchVal(form,val,skip)
        C = textscan(fid,form,1,'HeaderLines',skip);
        if ~(isscalar(C) && ~isempty(C{1}))
            error('match error')
        end
        if ~strcmp(val,C{1})
            switch val
                case 'HIGH'
                    if strcmp(C{1},'LOW')
                        parityFlip=true;
                    else
                        error('no match')
                    end
                case 'LOW'
                    if strcmp(C{1},'HIGH')
                        parityFlip=true;
                    else
                        error('no match')
                    end
                otherwise
                    error('no match')
            end
        end
    end

    function out=getVals(parity)
        
        matchVal('%% %[^%] %%','Evt+-',0);
        matchVal('%% %[^%] %%',parity,3);
        
        C = textscan(fid,'%f');
        if isvector(C{1}) && ~isempty(C{1})
            out=C{1};
        else
            error('bad values')
        end
        
        if parityFlip
            out=[min(out(1),pulseTimes(1))-1 ; out]; %yuck!
            parityFlip=false;
        end
    end

    function x=even(n)
        x=mod(n,2)==0;
    end

try
    [fid msg]=fopen(file,'rt');
    if ~isempty(msg)
        msg
    end
    
    if fid>2
        
        if exist('indexChan','var')
            n=4;
        else
            n=3;
            indexChan=nan;
        end
        
        for i = 1:n
            chanForm='%% CHANNEL %% %% %u8 %%';
            C = textscan(fid,chanForm,1);
            
            if isscalar(C)
                switch C{1}
                    case frameChan
                        if isempty(frames)
                            frames=getVals('LOW');
                        else
                            error('double frames')
                        end
                        
                        if ~even(sum(frames<pulseTimes(1)))
                            error('frames didn''t start lo')
                        end
                        origPulses=frames(frames>=pulseTimes(1) & frames<=pulseTimes(2));
                        if ~even(length(origPulses))
                            origPulses=origPulses(1:end-1);
                            if false % disabling cuz we currently cut off the end and may be mid-transition (see notes in 'double' protocol handler of compilePhysData.m/getPulses())
                                error('odd # frame transitions')
                            end
                        end
                        frames=origPulses(repmat([true false],1,length(origPulses)/2));
                    case stimChan
                        if isempty(stims)
                            stims=getVals('HIGH');
                        else
                            error('double stims')
                        end
                        
                        if ~even(sum(stims<pulseTimes(1)))
                            error('stim didn''t start high')
                        end
                        if sum(stims>=pulseTimes(1) & stims<=pulseTimes(2))>0
                            error('stim flipped during range')
                        end
                        stimsDone=true;
                    case phaseChan
                        if isempty(phases)
                            phases=getVals('LOW');
                        else
                            error('double phases')
                        end
                        
                        if ~even(sum(phases<pulseTimes(1)))
                            error('phase didn''t start lo')
                        end
                        if sum(phases>=pulseTimes(1) & phases<=pulseTimes(2))>0
                            error('phase flipped during range')
                        end
                        phasesDone=true;
                    case indexChan
                        if isempty(stimBreaks)
                            stimBreaks=getVals('LOW');
                        else
                            error('double index')
                        end
                        
                        if ~even(sum(stimBreaks<pulseTimes(1)))
                            error('index didn''t start lo')
                        end
                        stimBreaks=stimBreaks(stimBreaks>=pulseTimes(1) & stimBreaks<=pulseTimes(2));
                        if ~even(length(stimBreaks))
                            stimBreaks=stimBreaks(1:end-1);
                            if false % disabling cuz we currently cut off the end and may be mid-transition (see notes in 'double' protocol handler of compilePhysData.m/getPulses())
                                error('odd # stimBreaks ')
                            end
                        end
                        stimBreaks=stimBreaks(repmat([false true],1,length(stimBreaks)/2));
                        stimBreaksDone=true;
                    otherwise
                        error('got wrong chan')
                end
            else
                error('couldn''t read channel')
            end
            
        end
        
        if ~feof(fid)
            error('textscan didn''t get to end of file')
        end
        
        if ~stimBreaksDone && ~isnan(stimBreaks)
            error('dodn''t see index chan')
        end
        
        if any(cellfun(@isempty,{frames,origPulses}))
            error('no frames or originalPulses')
        end
        
        if ~all(stimsDone,phasesDone)
            error('stim or phase chan not seen')
        end
        
    else
        error('no file')
    end
    
    error('finally')
    
catch ex
    
    if exist('fid','var')
        s=fclose(fid);
        if s
            error('fclose error')
        end
    end
    
    if ~strcmp(ex.message,'finally')
        rethrow(ex)
    end
    
end

end