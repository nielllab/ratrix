function compilePhysTxt(targetDir,analysisDir,rec)

fprintf('\n\nstims for %s\n',targetDir)

chunkStarts=[rec.chunks.start_time];
chunkEnds=[rec.chunks.stop_time];

if any(chunkEnds<=chunkStarts)
    error('backwards chunk times')
end

chunkStarts
chunkEnds
rec.stimTimes

chunkNums=cell(1,size(rec.stimTimes,1));
for j=1:length(chunkNums)
    stimStart=rec.stimTimes{j,1};
    
    if j<length(chunkNums)
        stimStop=rec.stimTimes{j+1,1};
    else
        stimStop=max(chunkEnds);
    end
    
    if stimStop>max(chunkEnds)
        warning('stim extends past last chunk')
    end
    
    c=find(arrayfun(@(x,y) stimStart<=y && stimStop>=x,chunkStarts,chunkEnds));
    if isempty(c) || stimStart>=stimStop
        warning('no chunk for stim')
    else
        chunkNums{j}=c;
        if ~isscalar(c)
            warning('multiple chunks for stim')
        end
    end
    fprintf('\t%s: %d chunks (%g-%g)\n',rec.stimTimes{j,2},length(chunkNums{j}),stimStart,stimStop)
    chunkNums{j}
end


% for i=1:length(rec.chunks)
% 
%         if rec.chunks(i).start_time<=rec.stimTimes{j,1}
%             
%                             if isnan(chunkNums(j))
%                     chunkNums(j)=i;
%                 else
%                     error('more than one chunk for a stim')
%                 end
%             
%             if rec.chunks(i).stop_time>=rec.stimTimes
% 
%             elseif all(rec.chunks(i).start_time>=[rec.chunks.start_time]) && 
%                 
%             else
%                 error('stim crosses chunks')
%             end
%         end
%     end
% end
% 
% if any(isnan(chunkNums))
%     warning('stim outside of all chunks')
% end
% 
% chunkStarts=[rec.chunks.start_time];
% chunkEnds=[rec.chunks.stop_time];
% 
% chunkStarts
% chunkEnds
% rec.stimTimes
% 
% for i=1:size(rec.stimTimes,1)
%     stimStart=rec.stimTimes{i,1};
%     firstChunk = find(chunkStarts<=stimStart,1,'last');
%     if ~isscalar(firstChunk)
%         error('no chunk')
%     end
%     if stimStart>chunkEnds(firstChunk)
%         warning('stim after last chunk')
%         firstChunk=nan;
%         lastChunk=nan;
%         stimStart=nan;
%         stimEnd=nan;
%     else
%         if i~=size(rec.stimTimes,1)
%             stimEnd=rec.stimTimes{i+1,1};
%         else
%             if firstChunk~=length(chunkEnds)
%                 error('last stim is mroe than one chunk')
%             end
%             stimEnd=chunkEnds(end);
%         end
%         lastChunk=find(chunkEnds>=stimEnd,1,'first');
%         if ~isscalar(lastChunk)
%             warning('stimEnd after last chunkEnd')
%             lastChunk=length(chunkEnds);
%             stimEnd=chunkEnds(end);
%         end
%     end
%     
%     fprintf('\t%s: chunks %d-%d (%g-%g)\n',rec.stimTimes{i,2},firstChunk,lastChunk,stimStart,stimEnd)
% end

if false
    targetBinsPerSec=1000;
    
    drawSummary=1;
    forceStimRecompile=0;
    forcePhysRecompile=0;
    drawStims=1;
    
    for fileNum=1:length(rec)
        h=hash(rec(fileNum).baseFile,'SHA1');
        fileDir=fullfile(analysisDir,rec(fileNum).rat_id,datestr(rec(fileNum).date,'mm.dd.yy'),h);
        for chunkNum=1:length(rec(fileNum).chunks)
            chunk=['chunk' num2str(chunkNum)];
            suffix=[chunk '.' h '.txt'];
        end
        
        
        %3) enter time ranges of particular stims for each set of files (enter 0's for stimuli not shown):
        
        stimTimes=[];
        
        %stimTimes(:,:,1) = [
        %1425 1850;  % gaussian
        %];
        
        %stimTimes(:,:,2)=[
        %389.1093948    1589.1474132; % gaussian 2.5 std
        %1594.2254112   2874.2534028; % natural hateren t001
        %2879.3494116    4159.3714056 % white hateren t001
        %];
        
        
        %5) enter the repeat/unique format (one entry for each stim in stimTimes):
        
        pulsesPerRepeat=[];
        numRepeats=[];
        uniquesEvery=[];
        
        %pulsesPerRepeat=[100*5*60]; %[120000,800,800];
        %numRepeats=[1];             %[1,160,160];
        %uniquesEvery=[0];           %[0,5,5];
        
        
        
        %7) this file will call compilePhysData, which makes the "compiled data.txt" file
        % this makes loading the stimulus faster for the future
        % you should then call doAnalysis, which works on this file
        
        if isempty(stimTimes)
            stimTimes(:,:,fileNum)=[0 inf];
        end
        numStims=size(stimTimes(:,:,fileNum),1);
        
        compiledFile = sprintf('compiled stim.%s.mat',h);
        contents=what(fileDir);
        
    end
end
end