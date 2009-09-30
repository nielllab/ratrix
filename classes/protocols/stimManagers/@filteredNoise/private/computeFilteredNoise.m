%intent: stim output always btw 0-1 (DO NOT NORMALIZE to cover whole range - example would be dark segment of natural timeseries)
function stimulus=computeFilteredNoise(stimulus,hz)
stimulus.hz=hz;
filteringOK = false;

for i=1:length(stimulus.port)
    
    %convert to double to avoid int overflow problems
    sz=double(stimulus.patchDims{i}); %[height, width]
    
    scale=floor(stimulus.kernelSize{i}*sqrt(sum(sz.^2)));
    if rem(scale,2)==0
        scale=scale+1; %want nearest odd integer
    end
    
    bound=norminv(stimulus.bound{i},0,1); %only appropriate cuz marginal of mvnorm along one of its axes is norm with same variance as that eigenvector's eigenvalue
    
    %a multivariate gaussian's equidensity contours are ellipsoids
    %principle axes given by the eigenvectors of its covariance matrix
    %the eigenvalues are the squared relative lengths
    %sigma = ULU' where U's columns are unit eigenvectors (a rotation matrix) and L is a diagonal matrix of eigenvalues
    axes=eye(2); %note that interpretation depends on axis xy vs. axis ij
    rot=[cos(stimulus.orientation{i}) -sin(stimulus.orientation{i}); sin(stimulus.orientation{i}) cos(stimulus.orientation{i})];
    axes=rot*axes;
    sigma=axes*diag([stimulus.ratio{i} 1].^2)*axes';
    
    [a b]=meshgrid(linspace(-bound,bound,scale));
    kernel=reshape(mvnpdf([a(:) b(:)],0,sigma),scale,scale);
    kernel=stimulus.filterStrength{i}*kernel/max(kernel(:));
    
    kernel(ceil(scale/2),ceil(scale/2))=1; %so filterStrength=0 means identity
    
    dur=round(stimulus.kernelDuration{i}*hz);
    if dur==0
        k=kernel;
    else
        t=normpdf(linspace(-bound,bound,dur),0,1);
        
        for j=1:dur
            k(:,:,j)=kernel*t(j);
        end
    end
    
    k=k/sqrt(sum(k(:).^2));  %to preserve contrast (tho only for gaussian stimuli)
    %filtering effectively summed a bunch of independent gaussians with variances determined by the kernel entries
    %if X ~ N(0,a) and Y ~ N(0,b), then X+Y ~ N(0,a+b) and cX ~ N(0,ac^2)
    %must be a deep reason this is same as pythagorean
    %note that stim mean must be zero for this to work!
    
    if isstruct(stimulus.loopDuration{i})
        chunkSize=round(hz*stimulus.loopDuration{i}.chunkSeconds); %number of frames in a single repeat or unique
        frames=chunkSize*(1 + stimulus.loopDuration{i}.numCycles*stimulus.loopDuration{i}.numUniques); %the number of raw frames we need, before making the repeats/uniques
        totalFrames=stimulus.loopDuration{i}.numCycles*chunkSize*(stimulus.loopDuration{i}.numRepeats+stimulus.loopDuration{i}.numUniques);
    else
        frames=max(1,round(stimulus.loopDuration{i}*hz));
    end
    
    if ~isfield(stimulus.distribution{i},'seed') || strcmp(stimulus.distribution{i}.seed,'new')
        maxSeed=2^32-1;
        s=GetSecs;
        stimulus.seed{i}=round((s-floor(s))*maxSeed);
    else
        stimulus.seed{i}=double(stimulus.distribution{i}.seed);
    end
    stimulus.inds{i}=[];
    if isstruct(stimulus.distribution{i}) && ismember(stimulus.distribution{i}.special,{'sinusoidalFlicker','squareFlicker'})
        stimulus.distribution{i}.conditions=getShuffledCross({stimulus.distribution{i}.contrasts,stimulus.distribution{i}.freqs});
        noise=[];
        dur=(stimulus.loopDuration{i}/length(stimulus.distribution{i}.conditions))-stimulus.distribution{i}.gapSecs;
        for j=1:length(stimulus.distribution{i}.conditions)
            noise=[noise stimulus.distribution{i}.conditions{j}{1}*makeSinusoid(hz,stimulus.distribution{i}.conditions{j}{2},dur,stimulus.distribution{i}.special) zeros(1,round(stimulus.distribution{i}.gapSecs*hz))];
        end
        noise=.5+noise/2;
        
        %these should not be needed, and happen later anyway
        %noise(noise>1)=1;
        %noise(noise<0)=0;
        
        noise=permute(noise,[3 1 2]);
        repmat(noise,[sz 1]); %shouldn't this be noise=?
        
        if ~all(sz==1)
            error('the code is probably wrong for size other than [1 1]')
        end
    elseif ischar(stimulus.distribution{i}) && ismember( stimulus.distribution{i},  {'binary','uniform'} )
        % consider adding offset/contrast for these types
        rand('twister',stimulus.seed{i});
        noise=rand([sz frames]);
        if strcmp(stimulus.distribution{i},'binary')
            noise=(noise>.5);
        end
    elseif isstruct(stimulus.distribution{i})
        switch stimulus.distribution{i}.special
            case 'gaussian'
                
                randn('state',stimulus.seed{i});
                noise=randn([sz frames])*pickContrast(.5,stimulus.distribution{i}.clipPercent) +.5;
                
                hiClipInds=noise>1;
                loClipInds=noise<0;
                fprintf('*** gaussian: clipping %g%% of values (should be %g%%)\n',100*(sum(hiClipInds(:))+sum(loClipInds(:)))/numel(noise),100*stimulus.distribution{i}.clipPercent)
                
                %these will happen later, and screw up the gaussian-contrast-preserving filtering if done now
                %noise(hiClipInds)=1;
                %noise(loClipInds)=0;
                
                filteringOK=true;
            otherwise
                if ~isstruct(stimulus.loopDuration{i}) && stimulus.loopDuration{i}==0
                    frames=0;
                end
                [noise stimulus.inds{i}]=loadStimFile(stimulus.distribution{i}.special,stimulus.distribution{i}.origHz,hz,frames/hz,stimulus.startFrame{i});
                
                if size(noise,1)>1
                    noise=noise';
                end
                
                noise=permute(noise,[3 1 2]);
                repmat(noise,[sz 1]); %shouldn't this be noise=?
                
                if ~all(sz==1)
                    error('the code is probably wrong for size other than [1 1]')
                end
                
                switch stimulus.distribution{i}.clipType
                    case 'normalized'
                        %DO NOT NORMALIZE - want to keep clip relative to whole file
                        clipPoint=stimulus.distribution{i}.clipVal;
                    case 'ptile'
                        noise=normalize(noise);
                        clipPoint=prctile(noise,100*(1-stimulus.distribution{i}.clipVal));
                    otherwise
                        error('bad clipType')
                end
                
                clipInds=noise>clipPoint;
                fprintf('*** hateren: clipping %g%% of values (should be 1%% to match reinagel reid 2000)\n',100*sum(clipInds(:))/numel(noise))
                noise(clipInds)=clipPoint;
                noise=noise/clipPoint; %DO NOT NORMALIZE in case the whole clip is darker than the clip val or brighter than zero
                fprintf('*** hateren: %g%% values below 1/3 of max (should be 73%% to match reinagel reid 2000)\n',100*sum(noise(:)<(1/3)*max(noise(:)))/numel(noise))
        end
        
    else
        stimulus.distribution{i}
        error('bad distribution')
    end
    
    if isstruct(stimulus.loopDuration{i})
        if isstruct(stimulus.distribution{i}) && strcmp(stimulus.distribution{i}.special,'sinusoidalFlicker')
            error('can''t have rpts/unqs for sinusoidalFlicker')
        end
        
        new=nan*zeros(size(noise,1),size(noise,2),totalFrames);
        rpt=noise(:,:,1:chunkSize);
        
        clipNow=true;  %if we don't clip now, lowering the contrast will bring more values in range, so the stim won't be exactly preserved
        %but note clipping now slightly screws up gaussian contrast preserving filtering below
        if clipNow && ~all(stimulus.loopDuration{i}.centerThirdContrasts>=1)
            rpt(rpt<0)=0;
            rpt(rpt>1)=1;
        end
        
        start=1;
        unqPos=chunkSize+1;
        contrastMask=ones(size(rpt));
        contrastFix=zeros(size(rpt));
        contrastInds=round(chunkSize/3) : round(2*chunkSize/3);
        contrastMaskInd=0;
        for c=1:stimulus.loopDuration{i}.numCycles
            for r=1:stimulus.loopDuration{i}.numRepeats
                thisContrast=stimulus.loopDuration{i}.centerThirdContrasts(mod(contrastMaskInd,length(stimulus.loopDuration{i}.centerThirdContrasts))+1);
                contrastMask(:,:,contrastInds)=thisContrast;
                contrastFix(:,:,contrastInds)=(1-thisContrast)/2; %keeps mean at .5
                contrastMaskInd=contrastMaskInd+1;
                
                new(:,:,start:start+chunkSize-1)=rpt.*contrastMask+contrastFix;
                start=start+chunkSize;
            end
            for u=1:stimulus.loopDuration{i}.numUniques
                new(:,:,start:start+chunkSize-1)=noise(:,:,unqPos:unqPos+chunkSize-1);
                start=start+chunkSize;
                unqPos=unqPos+chunkSize;
            end
        end
        if any(isnan(new(:)))
            error('miss!')
        end
        if unqPos~=1+size(noise,3)
            error('miss!')
        end
        noise=new;
    end
    
    try
        stimulus.sha1{i} = hash(noise,'SHA-1');
    catch ex
        if ~isempty(findstr('OutOfMemoryError',ex.message))
            stimulus.sha1{i} = hash(noise(1:1000),'SHA-1');
        else
            rethrow(ex);
        end
    end
    
    t=zeros(size(k));
    t(ceil(length(t(:))/2))=1;
    if all(rem(size(k),2)==1) && all(k(:)==t(:))
        %identity kernel, don't waste time filtering
        stim=noise;
        for j=1:4
            beep;pause(.1);
        end
    else
        if ~filteringOK
            error('you shouldn''t filter non-gaussian stims')
        end
        
        theMean=mean(noise(:));
        tic
        %stim=convn(noise,k,'same'); %slower than imfilter
        stim=imfilter(noise-theMean,k,'circular')+theMean; %allows looping, does it keep edges nice?

        %for reasonable stims, takes 6x realtime on fast systems
        %i have circular filtering worked out by hand in matlab, to translate to gpu shader to get realtime speed
        %tho note problems: http://tech.groups.yahoo.com/group/psychtoolbox/message/8742

        %http://blogs.mathworks.com/steve/2006/11/28/separable-convolution-part-2/#comment-21123
        %alternative: work out how to do in fourier domain
        %from cris niell: ifft(randn*freqs*exp(2*pi*i*phases)  (here, randn and phases are space x space x time)
        %requires some fftshifting, symmetry issues, etc.
        
        fprintf('took %g to filter noise\n',toc)
    end
    
    stim(stim>1)=1;%DO NOT NORMALIZE!!!
    stim(stim<0)=0;
    
    saveOutput=false;
    if saveOutput
        bitDepth=8;
        if size(stim,1)==1 && size(stim,2)==1 && isstruct(stimulus.loopDuration{i})
            numChunks=stimulus.loopDuration{i}.numCycles*(stimulus.loopDuration{i}.numUniques + stimulus.loopDuration{i}.numRepeats);
            plottable=reshape(floor(stim*2^bitDepth),chunkSize,numChunks)+repmat(2^bitDepth*(0:numChunks-1),chunkSize,1);
            save(sprintf('filteredNoise_%d_%s_%.100g.mat',i,datestr(now,30),GetSecs),'plottable','stim')
        else
            warning('can''t save/plot stim that isn''t 1x1xn or doesn''t have rpts/unqs')
        end
    end
    
    comparePreAndPostFilteredDistributions=false;
    if comparePreAndPostFilteredDistributions
        % for some reason, filtered is coming out slightly lower contrast... why?  rounding errors?
        
        sca
        noise(noise>1)=1;
        noise(noise<0)=0;
        [h b]=hist(stim(:),1000);
        h2=hist(noise(:),b);
        subplot(2,1,1)
        plot(b,[h' h2'])
        legend({'filtered','unfiltered'})
        xlim([-.1 1.1])
        subplot(2,1,2)
        plot(b,h-h2)
        hold on
        plot(b,ones(1,length(b)))
        legend('filtered-unfiltered')
        xlim([-.1 1.1])
        keyboard
    end
    
    if isinf(stimulus.numLoops{i})
        stimulus.cache{i}=stim;
    else
        f=floor(stimulus.numLoops{i});
        r=round((stimulus.numLoops{i}-f)*size(stim,3));
        stimulus.cache{i}=repmat(stim,[1,1,f]);
        stimulus.cache{i}(:,:,end+1:end+r)=stim(:,:,1:r);
    end
    
end