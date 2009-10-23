function compilePhysTxt(targetDir,analysisDir,wavemarkDir,rec,force,targetBinsPerSec)
verbose=false;

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
        
        for chunkNum=c
            fileNames=[];
            [garbage code]=fileparts(targetDir);
            
            fileNames.stimFile=constructPath(targetDir,'stim',code,'mat');
            fileNames.physFile=constructPath(targetDir,'phys',code,'mat');
            fileNames.pulseFile=constructPath(analysisDir,'pulse',code,'txt');
            fileNames.pokesFile=constructPath(analysisDir,'pokes',code,'txt');
            
            chunkName=sprintf('chunk%d',chunkNum);
            [garbage code]=fileparts(wavemarkDir);
            
            fileNames.spikesFile=constructPath(fullfile(wavemarkDir,chunkName),['spks.' chunkName],code,'txt');
            fileNames.wavemarkFile=constructPath(fullfile(wavemarkDir,chunkName),['waveforms.' chunkName],code,'txt');
            
            thisStart=max(chunkStarts(chunkNum),stimStart);
            thisStop=min(chunkEnds(chunkNum),stimStop);

            stimName=sprintf('%d.%s',j,rec.stimTimes{j,2});
            stimName=stimName(~ismember(stimName,['<>/\?:*"|'])); %TODO: check for excluded filename characters on osx
            z=sprintf('%g',rec.chunks(chunkNum).cell_Z);
            tRange=sprintf('%g-%g',thisStart,thisStop);
            chunkName=sprintf('%d.%s',chunkNum,code);
            desc=[stimName '.z.' z '.t.' tRange '.chunk.' chunkName];
            
            fileNames.targetFile=fullfile(targetDir,desc,[desc '.compiled.mat']);

                recM=rec;
                recM.chunks=rec.chunks(chunkNum);
                recM.stimTimes=[];
                compilePhysData(fileNames,[thisStart thisStop],recM,rec.stimTimes{j,2},targetBinsPerSec,force);
        end
    end
end
end

function out=constructPath(pth,name,code,sfx)
out=fullfile(pth,[name '.' code '.' sfx]);
if ~exist(out,'file')
    error('no such file')
end
end