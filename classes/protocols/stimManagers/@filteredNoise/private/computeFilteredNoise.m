function stimulus=computeFilteredNoise(stimulus,hz)
stimulus.hz=hz;

for i=1:length(stimulus.port)

    sz=stimulus.patchDims{i}; %[height, width]

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

    k=k/sqrt(sum(k(:).^2));  %to preserve contrast
    %filtering effectively summed a bunch of independent gaussians with variances determined by the kernel entries
    %if X ~ N(0,a) and Y ~ N(0,b), then X+Y ~ N(0,a+b) and cX ~ N(0,ac^2)
    %must be a deep reason this is same as pythagorean

    if isstruct(stimulus.loopDuration{i})
        chunkSize=round(hz*stimulus.loopDuration{i}.cycleDurSeconds/(1+double(stimulus.loopDuration{i}.numRepeatsPerUnique))); %number of frames in a single repeat or unique
        frames=chunkSize*(1+double(stimulus.loopDuration{i}.numCycles)); %the number of raw frames we need, before making the repeats/uniques
        totalFrames=double(stimulus.loopDuration{i}.numCycles)*chunkSize*(1+double(stimulus.loopDuration{i}.numRepeatsPerUnique));
    else
        frames=max(1,round(stimulus.loopDuration{i}*hz));
    end

    maxSeed=2^32-1;
    s=GetSecs;
    stimulus.seed{i}=round((s-floor(s))*maxSeed);
    stimulus.inds{i}=[];
    if isstruct(stimulus.distribution{i}) && strcmp(stimulus.distribution{i}.special,'sinusoidalFlicker')
        stimulus.distribution{i}.conditions=getShuffledCross({stimulus.distribution{i}.contrasts,stimulus.distribution{i}.freqs});
        noise=[];
        dur=(stimulus.loopDuration{i}/length(stimulus.distribution{i}.conditions))-stimulus.distribution{i}.gapSecs;
        for j=1:length(stimulus.distribution{i}.conditions)
            noise=[noise stimulus.distribution{i}.conditions{j}{1}*makeSinusoid(hz,stimulus.distribution{i}.conditions{j}{2},dur) zeros(1,round(stimulus.distribution{i}.gapSecs*hz))];
        end
        noise=noise-.5;
        noise=permute(noise,[3 1 2]);
        repmat(noise,[sz 1]);
    elseif ischar(stimulus.distribution{i})
        switch stimulus.distribution{i}
            case 'gaussian'
                randn('state',stimulus.seed{i});
                noise=randn([sz frames]);
            case {'binary','uniform'}
                rand('twister',stimulus.seed{i});
                noise=rand([sz frames]);
                if strcmp(stimulus.distribution{i},'binary')
                    noise=(noise>.5);
                end
                noise=noise-.5;
            otherwise
                if ~isstruct(stimulus.loopDuration{i}) && stimulus.loopDuration{i}==0
                    frames=0;
                end
                [noise stimulus.inds{i}]=loadStimFile(stimulus.distribution{i},stimulus.origHz{i},hz,frames/hz,stimulus.startFrame{i});
                noise=noise-.5;
                if size(noise,1)>1
                    noise=noise';
                end
                %noise=-.5:.01:.5;
                noise=permute(noise,[3 1 2]);
                repmat(noise,[sz 1]);
        end
        if isstruct(stimulus.loopDuration{i})
            new=nan*zeros(size(noise,1),size(noise,2),totalFrames);
            rpt=noise(:,:,1:chunkSize);
            start=1;
            unqPos=chunkSize+1;
            for c=1:stimulus.loopDuration{i}.numCycles
                for r=1:stimulus.loopDuration{i}.numRepeatsPerUnique
                    new(:,:,start:start+chunkSize-1)=rpt;
                    start=start+chunkSize;
                end
                new(:,:,start:start+chunkSize-1)=noise(:,:,unqPos:unqPos+chunkSize-1);
                start=start+chunkSize;
                unqPos=unqPos+chunkSize;
            end
            if any(isnan(new(:)))
                error('miss!')
            end
            if unqPos~=1+size(noise,3)
                error('miss!')
            end
            noise=new;
        end
    else
        '***'
        stimulus.distribution{i}
        '***'
        error('bad distribution')
    end

    try
        stimulus.sha1{i} = hash(noise,'SHA-1');
    catch 
        ex=lasterror;
        if ~isempty(findstr('OutOfMemoryError',ex.message))
            stimulus.sha1{i} = hash(noise(1:1000),'SHA-1');
        else
            rethrow(ex);
        end
    end

    %         [a b] = hist(noise(:),100);
    %         std(noise(:))

    t=zeros(size(k));
    t(ceil(length(t(:))/2))=1;
    if all(rem(size(k),2)==1) && all(k(:)==t(:))
        %identity kernel, don't waste time filtering
        stim=noise;
        for j=1:4
            beep;pause(.1);
        end
    else
        tic
        %stim=convn(noise,k,'same'); %slower than imfilter
        stim=imfilter(noise,k,'circular'); %allows looping, does it keep edges nice?
        toc
    end

    %         c = hist(stim(:),b);
    %         std(stim(:))
    %
    %         figure
    %         plot(b,[a' c']);

    stimulus.cache{i}=stim;

    %         i
    %         stimulus.orientations{i}
    %         size(stim)
    %         imagesc(stim(:,:,round(size(stim,3)/2)))

end