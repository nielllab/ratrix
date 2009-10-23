function compilePhysTxt(targetDir,analysisDir,wavemarkDir,rec,force)
verbose=true;

chunkStarts=[rec.chunks.start_time];
chunkEnds=[rec.chunks.stop_time];

if any(chunkEnds<=chunkStarts)
    error('backwards chunk times')
end

if verbose
    fprintf('\n\nstims for %s\n',targetDir)
    chunkStarts
    chunkEnds
    rec.stimTimes
end

numStims=size(rec.stimTimes,1);

for j=1:numStims
    stimStart=rec.stimTimes{j,1};

    if j<numStims
        stimStop=rec.stimTimes{j+1,1};
    else
        stimStop=max(chunkEnds);
    end
    
    if stimStop>max(chunkEnds) && verbose
        warning('stim extends past last chunk')
    end
    
    c=find(arrayfun(@(x,y) stimStart<=y && stimStop>=x,chunkStarts,chunkEnds));
    if isempty(c) || stimStart>=stimStop
        if verbose
            warning('no chunk for stim')
        end
    else
        if ~isscalar(c) && verbose
            warning('multiple chunks for stim')
        end
        
        fprintf('\n')
        for chunkNum=c
            [garbage code]=fileparts(targetDir);
            
            stimFile=constructPath(targetDir,'stim',code,'mat');
            physFile=constructPath(targetDir,'phys',code,'mat');
            pulseFile=constructPath(analysisDir,'pulse',code,'txt');
            pokesFile=constructPath(analysisDir,'pokes',code,'txt');
            
            chunkName=sprintf('chunk%d',chunkNum);
            [garbage code]=fileparts(wavemarkDir);
            
            spikesFile=constructPath(fullfile(wavemarkDir,chunkName),['spks.' chunkName],code,'txt');
            wavemarkFile=constructPath(fullfile(wavemarkDir,chunkName),['waveforms.' chunkName],code,'txt');
            
            thisStart=max(chunkStarts(chunkNum),stimStart);
            thisStop=min(chunkEnds(chunkNum),stimStop);
            
            fileName=sprintf('%s: %d.%s.chunk%d',targetDir,j,rec.stimTimes{j,2},chunkNum);
            fprintf('\t%s: %g-%g\n',fileName,thisStart,thisStop);
        end
    end
    fprintf('\n')
end
fprintf('\n')

if false
    fprintf('\ndoing waveforms\n')
    tic
    doWaveforms(baseDir,params.base,params.spkChan,params.spkCode);
    toc
end

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

function out=constructPath(pth,name,code,sfx)
out=fullfile(pth,[name '.' code '.' sfx]);
if ~exist(out,'file')
    error('no such file')
end
end