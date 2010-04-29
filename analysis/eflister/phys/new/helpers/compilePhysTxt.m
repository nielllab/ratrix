function compilePhysTxt(targetDir,analysisDir,wavemarkDir,rec,force,targetBinsPerSec,figureBase,analysisFilt,tmpFile)
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
            fileNames.tmpFile=tmpFile;
            
            chunkName=sprintf('chunk%d',chunkNum);
            [garbage code]=fileparts(wavemarkDir);
            
            fileNames.spikesFile=constructPath(fullfile(wavemarkDir,chunkName),['spks.' chunkName],code,'txt');
            fileNames.wavemarkFile=constructPath(fullfile(wavemarkDir,chunkName),['waveforms.' chunkName],code,'txt');
            
            thisStart=max(chunkStarts(chunkNum),stimStart);
            thisStop=min(chunkEnds(chunkNum),stimStop);
            
            stimName=sprintf('%d.%s',j,rec.stimTimes{j,2});
            stimName=sanitize(stimName);
            z=sprintf('%g',rec.chunks(chunkNum).cell_Z);
            tRange=sprintf('%g-%g',thisStart,thisStop);
            chunkName=sprintf('%d.%s',chunkNum,code);
            desc=[stimName '.z.' z '.t.' tRange '.chunk.' chunkName];
            
            fileNames.targetFile=fullfile(targetDir,desc,[desc '.compiled.mat']);
            
            if IsWin 
                if ~isempty(findstr(fileNames.targetFile,'2.junk.z.47.34.t.2012.45-2042.39.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80'))
                %temp hack cuz windows printf rounds differently than osx (see http://www.mathworks.com/support/service_requests/Service_Request_Detail.do?ID=242675)
                %better to search for 2042.39 and replace with 2042.38
                    fileNames.targetFile='F:\a\b\164\04.15.09\acf4f35b54186cd6055697b58718da28e7b2bf80\2.junk.z.47.34.t.2012.45-2042.38.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80\2.junk.z.47.34.t.2012.45-2042.38.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80.compiled.mat';
                elseif ~isempty(findstr(fileNames.targetFile,'3.gaussian.z.47.34.t.2042.39-4641.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80'))
                    %2042.39 -> 2042.38
                    fileNames.targetFile='F:\a\b\164\04.15.09\acf4f35b54186cd6055697b58718da28e7b2bf80\3.gaussian.z.47.34.t.2042.38-4641.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80\3.gaussian.z.47.34.t.2042.38-4641.chunk.1.acf4f35b54186cd6055697b58718da28e7b2bf80.compiled.mat';
                elseif ~isempty(findstr(fileNames.targetFile,'2.sinusoid.z.38.885.t.1401.96-1572.42.chunk.1.4b45921ce9ef4421aa984128a39f2203b8f9a381'))
                    %1572.42 -> 1572.41
                    fileNames.targetFile='F:\a\b\188\04.23.09\4b45921ce9ef4421aa984128a39f2203b8f9a381\2.sinusoid.z.38.885.t.1401.96-1572.41.chunk.1.4b45921ce9ef4421aa984128a39f2203b8f9a381\2.sinusoid.z.38.885.t.1401.96-1572.41.chunk.1.4b45921ce9ef4421aa984128a39f2203b8f9a381.compiled.mat';
                elseif ~isempty(findstr(fileNames.targetFile,'3.junk.z.38.885.t.1572.42-1576.86.chunk.1.4b45921ce9ef4421aa984128a39f2203b8f9a381'))
                    %1572.42 -> 1572.41
                    fileNames.targetFile='F:\a\b\188\04.23.09\4b45921ce9ef4421aa984128a39f2203b8f9a381\3.junk.z.38.885.t.1572.41-1576.86.chunk.1.4b45921ce9ef4421aa984128a39f2203b8f9a381\3.junk.z.38.885.t.1572.41-1576.86.chunk.1.4b45921ce9ef4421aa984128a39f2203b8f9a381.compiled.mat';                    
                end
            end
            
            recM=rec;
            recM.chunks=rec.chunks(chunkNum);
            recM.stimTimes=[];
            compilePhysData(fileNames,[thisStart thisStop],[stimStart stimStop],recM,rec.stimTimes{j,2},targetBinsPerSec,force,figureBase,analysisFilt);
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