function [noise outInds]=loadStimFile(fileName,oldHz,newHz,duration,startFrame)

if 2==exist([fileName '.mat'],'file')
    noise=load([fileName '.mat']);
    noise=noise.noise;
elseif 2==exist([fileName '.txt'],'file')
    tic
    noise=load([fileName '.txt']);
    fprintf('load took %g secs\n',toc)
    
    %textscan is slightly slower
    %     tic
    %     fid = fopen([fileName '.txt']);
    %     C = textscan(fid, '%d');
    %     fclose(fid);
    %     fprintf('textscan took %g secs\n',toc)
    %     noise=C{1};
    
    encodeAsInt=false;
    if encodeAsInt %no file size gain, but RAM gain
        if any(noise ~= round(noise))
            error('file contained some non-integers')
        end
        
        noise=noise-min(noise);
        
        bits=ceil(log2(max(noise)));
        bits=num2str(2^nextpow2(bits));
        if ismember(bits,{'8' '16' '32' '64'})
            intType=['uint' bits];
            noise=feval(intType,noise);
            if ~strcmp(class(noise),intType)
                error('cast didn''t work')
            end
        else
            error('couldn''t encode as uints')
        end
    end
    
    save([fileName '.mat'],'noise');
else
    error('can''t find file')
end

if ~(isvector(noise) && isreal(noise) && isnumeric(noise))
    error('file contents not real numeric vector')
end

noise=normalize(noise); %IMPORTANT that this is relative to the whole file!

outInds=[];
if duration>0
    lastAvailable=length(noise)-duration*oldHz+1;
    if strcmp(startFrame,'randomize')
        start=ceil(rand*lastAvailable);
    elseif startFrame>0 && startFrame<=lastAvailable
        start=double(startFrame);
    else
        error('startFrame is too large and would require wrapping around to beginning of file')
    end
    inds=start:start+duration*oldHz-1;
    noise=noise(inds);
    outInds=[inds(1) inds(end)];
end

mins=(0:(length(noise)-1))/oldHz/60;
doplot=false;
if doplot
    plot(mins,noise,'r')
    hold on
end

if oldHz~=newHz
    method='resample';
    tic
    switch method
        case 'resample'
            
            newNoise=resample(noise,newHz,oldHz);
            
        case 'integrate'
            
            newMins=0:1/(newHz*60):max(mins);
            
            newNoise=zeros(1,length(newMins));
            
            for m=1:length(newNoise)
                
                inds=find(mins>=newMins(m) & mins<newMins(m)+1/(newHz*60));
                newNoise(m)=newNoise(m)+sum(noise(inds));
                
                if m~=1
                    p=(newMins(m)-mins(min(inds)-1))*60*oldHz;
                    newNoise(m-1)=newNoise(m-1)+p*noise(min(inds)-1);
                    newNoise(m)=newNoise(m)+(1-p)*noise(min(inds)-1);
                end
                
                if rand>.99
                    fprintf('%g%% done\n',100*m/length(newNoise))
                end
            end
            
            if doplot
                plot(newMins,normalize(newNoise),'b')
                plot(newMins,normalize(resample(noise,newHz,oldHz)),'g')
                legend({'original','integrated','resampled'})
            end
            
        otherwise
            error('bad method')
    end
    fprintf('resample took %g secs\n',toc);
    
    if length(noise)/oldHz~=length(newNoise)/newHz
        error('resampling gave wrong length for new sig')
    end
    noise=newNoise;
    %noise=normalize(noise); MUST NOT NORMALIZE!  resampling has added artifacts outside of expected range such that normalizing will reduce contrast!
    %                                             plus, if you are in a dark chunk of the file, you want it to stay that way!
    noise(noise>1)=1;
    noise(noise<0)=0;
end

end