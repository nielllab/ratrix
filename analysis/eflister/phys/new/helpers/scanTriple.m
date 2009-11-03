function [frames,origPulses]=scanTriple(file,frameChan,stimChan,phaseChan,pulseTimes)
frames=[];
stims=[];
phases=[];

%frames - hi during calc, lo while waiting for flip (need to verify this -- we'll call the frame at the lo-hi transition)
%stims - hi during stim phases (we'll require hi throughout)
%phases - just lo-hi-lo pulses at phase boundaries (we'll require none throughout)

% example pulse file:
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

% file = '/Volumes/Maxtor One Touch II/eflister phys/physDB/164/04.07.09/891c8c7f8286129461df5aa06b799ead54d28176/pulse.891c8c7f8286129461df5aa06b799ead54d28176.txt';
% frameChan=2;
% stimChan=3
% phaseChan=4;

    function matchVal(form,val,skip)
        C = textscan(fid,form,1,'HeaderLines',skip);
        if ~(isscalar(C) && ~isempty(C{1}) && strcmp(val,C{1}))
            error('match error')
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
        
        for i = 1:3
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