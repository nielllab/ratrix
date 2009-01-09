function test10bit(mode,colorRange)
%in 10 bit mode there should be at most 1 transition in a color range of 1
%(like the default)
% test10bit([],[1 2])
% test10bit([],[1 50])  % example of more steps visible
% test10bit([],[1 4])  % hope you see something like this

if ~exist('mode','var') || isempty(mode)
    mode='spatial';
end

if ~exist('colorRange','var') || isempty(colorRange)
    colorRange=[1:2]; %this is the color index
end



switch mode
    case 'spatial'

        try
            p.screenNumber = max(Screen('Screens'));
            Screen('Preference', 'SkipSyncTests', 1);

            if 0
                PsychImaging('PrepareConfiguration');
                PsychImaging('AddTask', 'General', 'FloatingPoint16Bit');
                PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
                %PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
                [windowPtr, rect] = PsychImaging('OpenWindow', p.screenNumber, 255, [], 32, 2);
            else
                [windowPtr rect] = Screen('OpenWindow', p.screenNumber, 255, [], 32, 2);
            end
            %res=Screen('Resolution', windowPtr)

            plainGammaTable=repmat([0:255]/255,3,1)';
            %highRangeLowInds=repmat([linspace(0,100,10) linspace(110,255,246)]/255,3,1)';
            %Screen('LoadNormalizedGammaTable', windowPtr, highRangeLowInds);

            ctr=[rect(3:4) rect(3:4)]/2;
            colorIndices=linspace(colorRange(1),colorRange(2),8);
            boxWidths=fliplr([2:9]*30);
            for reps=1:3 % flash it on and off
                for i=1:length(colorIndices)
                    boxOff=boxWidths(i)*[-1 -1 1 1];
                    Screen('FillRect', windowPtr, colorIndices(i), ctr+boxOff);
                end
                Screen('Flip', windowPtr);
                waitSecs(0.4)
                Screen('FillRect', windowPtr, colorIndices(1), ctr+(boxWidths(1)*[-1 -1 1 1]));
                Screen('Flip', windowPtr);
                waitSecs(0.4)
            end
            info = Screen('GetWindowInfo',windowPtr)
            sca
        catch
            sca
            e=lasterror
            e.stack
            rethrow(e)

        end
    case 'temporal'
        error('not yet')
    otherwise
        mode
        error('bad mode')
end
