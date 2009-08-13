function [image deltas]=prepareImages(ims,alphas,screenSize,threshPct,pctScreenFill,backgroundcolor, normalizeHistograms,selectedSizes,selectedRotation)
%[image deltas]=prepareImages(ims,alphas,screenSize,threshPct,pctScreenFill,[backgroundcolor],[normalizeHistograms],[selectedSizes],[selectedRotation])
%INPUTS
% ims                   cell array of image matrices, any real numeric type, no restrictions on values
% screenSize
% threshPct
% pctScreenFill         
% backgroundcolor       uint8, default black
% normalizeHistograms	default true
%OUTPUTS
% image                 cell array of prepared images, can be horizontally concatenated
% deltas                ratio errors in area normalization (imresize does not work sub-pixel)
%
% 12/15/08 - fli added static-mode rotation/scaling

if ~exist('backgroundcolor','var')
    backgroundcolor=uint8(0);
elseif ~isa(backgroundcolor,'uint8')
    error('backgroundcolor must be uint8')
end

if ~exist('normalizeHistograms','var')
    normalizeHistograms=true;
end
if ~exist('selectedSizes','var')
    selectedSizes=ones(1,length(ims));
end
if ~exist('selectedRotation','var')
    selectedRotation=0;
end


%%%%%%%%%%%%%%%%%%%%%%%%
% 12/15/08 - do imrotate
for i=1:length(ims)
    ims{i} = imrotate(ims{i},-selectedRotation); % negative of selectedRotation because PTB uses clockwise orientation, whereas imrotate uses CCW
    alphas{i} = imrotate(alphas{i},-selectedRotation);
end

%%%%%%%%%%%%%%%%%%%%%%%%
maxPixel=0;
subjects={};
areas=[];
for i=1:length(ims)
    if ~isempty(ims{i})
        ims{i}=double(ims{i});
        if all(size(alphas{i})==size(ims{i})) && isinteger(alphas{i}) && all(alphas{i}(:)>=0) && all(alphas{i}(:)<=intmax('uint8')) % && max(alphas{i}(:))>200 %why did i think i needed this?
            ims{i}=(double(alphas{i})/double(intmax('uint8'))).*ims{i}; %essentially composites alpha against a black background
        else
            size(alphas{i})
            size(ims{i})
            isinteger(alphas{i})
            all(alphas{i}(:)>=0)
            all(alphas{i}(:)<=intmax('uint8'))
            max(alphas{i}(:))>200
            error('unexpected alpha')
        end

        imax=max(ims{i}(:));
        maxPixel=max(maxPixel,imax);
        %alphas{i}=alphas{i}>0;

        [subjects{i} areas(i) alphas{i}]=cropSubject(ims{i},alphas{i},imax*threshPct,uint32(floor(pctScreenFill.*screenSize./[1 length(ims)])));
    else
        subjects{i}=[];
        areas(i)=0;
    end
end


'equalizing areas'
[equalized deltas alphas]=equalizeAreas(subjects,alphas,areas,maxPixel,threshPct);



for i=1:length(equalized)
    size(equalized{i})


end

if normalizeHistograms
    'equalizing hists'
    equalized=equalizeHistograms(equalized,maxPixel);
    'computed'
end
% figure
% subplot(2,1,1)
% doHists(subjects,maxPixel,'originals');
% subplot(2,1,2)
% doHists(equalized,maxPixel,'equalized');

%need black background for two reasons -- don't want to saturate out the
%visual system and don't want aspect ratio of boudning box to be
%discriminable

%original=alignImages(subjects,screenSize,0,0);
image=alignImages(equalized,screenSize,backgroundcolor,backgroundcolor);
%figure
%imshow(image)
%figure
%imshow(original)

%image=[image;original];

%figure
%imshow(medfilt2(image));

%image=medfilt2(image);

end

    function [images deltas alphas]=equalizeAreas(images,alphas,areas,bgColor,threshPct)
        method='ratio';
        maxLoops=30;
        deltas=cell(1,length(images));
        target=min(areas(~cellfun(@isempty,images)));
        for i=1:length(images)
            if ~isempty(images{i})
                if areas(i)>target %had to switch to shrinking rather than growing, cuz otherwise can exceed screen size.  this is cuz images typically already cropped and zoomed to max size for screen, any increase due to an area adjustment can easily exceed this.

                    %images{i}(isnan(images{i}))=bgColor; %may still be necessary for pixel method?
                    switch method
                        case 'pixel'
                            n=1;
                            last=0;
                            verts={};
                            horizs={};
                            while any(last(end,:)<max(areas)) %need to change this to shrinking!
                                %n
                                verts{n}=imresize(images{i},size(images{i})+[1 nan]*n);
                                horizs{n}=imresize(images{i},size(images{i})+[nan 1]*n);
                                'should error now cuz calling cropSubject with empty alpha -- haven''t updated this code!'
                                [verts{n} last(n,1)]=cropSubject(verts{n},[],bgColor*threshPct);
                                [horizs{n} last(n,2)]=cropSubject(horizs{n},[],bgColor*threshPct);
                                n=n+1;
                            end
                            last=last-max(areas);
                            best=min(last(:));
                            [r c]=ind2sub(size(last),find(last==best));
                            switch c(1)
                                case 1
                                    images{i}=verts{r(1)};
                                case 2
                                    images{i}=horizs{r(1)};
                                otherwise
                                    error('should never happen')
                            end
                        case 'ratio'
                            clear temp
                            clear tempAlpha

                            tolerance=.0001;
                            factorRange=[0 2*target/areas(i)];
                            delta=10*tolerance;
                            m=1;
                            bestBigger={};
                            bestSmaller={};
                            while abs(delta)>tolerance && m<maxLoops
                                beep %feedback when ptb screen is up -- ratrix can appear to be dead for long periods without this -- better would be screen output, but that requries some rearchitecting
                                
                                factor=mean(factorRange);

                                factorRange
                                target
                                areas

                                temp=uint8(images{i});%sets nans to zeros, plus imresize exceeds dynamic range on double input, and is much slower
                                temp=imresize(temp,factor);
                                tempAlpha=imresize(alphas{i},size(temp));
                                temp=double(temp);
                                [temp areas(i)]=cropSubject(temp,tempAlpha,bgColor*threshPct);

                                delta=(areas(i)/target)-1;
                                if delta>0
                                    factorRange(2)=factor;
                                    if isempty(bestBigger) || bestBigger{1}>delta
                                        bestBigger{1}=delta;
                                        bestBigger{2}=size(temp);
                                        bestBigger{3}=tempAlpha;
                                        bestBigger{4}=temp;
                                    end
                                else
                                    factorRange(1)=factor;
                                    if isempty(bestSmaller) || bestSmaller{1}<delta
                                        bestSmaller{1}=delta;
                                        bestSmaller{2}=size(temp);
                                        bestSmaller{3}=tempAlpha;
                                        bestSmaller{4}=temp;
                                    end
                                end

                                'temp size'
                                [size(temp) areas(i)]

                                %resize by fractions that don't change the image
                                %size doesn't change the number of non-nan pixels,
                                %even when passing doubles to resize -- so can't
                                %get perfect match :(   (thought this used to work)
                                %but anyway, that means we don't have to go to
                                %maxLoops
                                if ~isempty(bestBigger) && ~isempty(bestSmaller) && (all(bestBigger{2}-bestSmaller{2}==[0 1]) || all(bestBigger{2}-bestSmaller{2}==[1 0]))
                                    if bestBigger{1}>abs(bestSmaller{1})
                                        delta = bestSmaller{1};
                                        tempAlpha=bestSmaller{3};
                                        temp=bestSmaller{4};
                                    else
                                        delta = bestBigger{1};
                                        tempAlpha=bestBigger{3};
                                        temp=bestBigger{4};
                                    end
                                    'stopping early'
                                    break
                                end

                                m=m+1;
                            end
                            if abs(delta)>tolerance
                                warning('area matching didn''t converge - delta is %g', delta)
                            end
                            alphas{i}=tempAlpha;
                            deltas{i}=delta;
                            images{i}=temp;
                        otherwise
                            error('bad method')
                    end
                elseif areas(i)<target
                    error('found a non-empty image with area less than the target, but target should be smallest non-empty area')
                end
            end
        end
    end


    function [subject area alpha]=cropSubject(image,alpha,thresh,targetDims)

        subject=nanBackground(image,alpha,thresh);

        crop=~isnan(subject);
        sides=sum(crop);
        topAndBottom=sum(crop');
        subject=subject(min(find(topAndBottom)):max(find(topAndBottom)),min(find(sides)):max(find(sides)));
        alpha=    alpha(min(find(topAndBottom)):max(find(topAndBottom)),min(find(sides)):max(find(sides)));

        if exist('targetDims','var') && ~isempty(subject)
            if isvector(targetDims) && length(targetDims)==2 && isinteger(targetDims) && all(targetDims>0)
                %subject(isnan(subject))=0;
                subject=uint8(subject); %will turn nans to zeros, should check bit depth is 8, seems to be necessary to not have doubles or imresize goes outside dynamic range

                subjectTaller = imresize(subject, [double(targetDims(1)) nan]);

                if any(size(subjectTaller)>targetDims)
                    subjectWider = imresize(subject, [nan double(targetDims(2))]);
                    if any(size(subjectWider)>targetDims)
                        error('resizing didn''t work')
                    else
                        subject=subjectWider;
                    end
                else
                    subject=subjectTaller;
                end

                if any(subject(:)>intmax('uint8')) || any(subject(:)<0)
                    error('imresize exceeded dynamic range')
                end

                subject=double(subject);

                alpha=imresize(alpha,size(subject));
                subject=nanBackground(subject,alpha,thresh);
            else
                error('bad targetDims')
            end
        end

        area=sum(~isnan(subject(:)));



        % imshow(uint8(subject));
        % class(subject)
        % [min(subject(:)) max(subject(:))]
        % sum(isnan(subject(:)))/prod(size(subject))
        % 'this is subj4'
        % pause
        %
        % imshow(alpha);
        % class(alpha)
        % [min(alpha(:)) max(alpha(:))]
        % 'this is alpha'
        % pause

    end

    function image=nanBackground(image,alpha,thresh)
        if isempty(alpha) %|| true %this true is just temporary, see else clause
            mask=image>=thresh;
            background=bwselect(mask,[1 1 size(mask,2) size(mask,2)],[1 size(mask,1) 1 size(mask,1)],4);
            error('empty alpha -- no longer supported!')
        else %for some reason this is causing the area equalization to get bigger than the screen size every few trials
            %until i can figure this out, we don't use alpha to determine background
            if all(size(image)==size(alpha))
                background = alpha==0;
            else
                error('image and alpha not same size')
            end
        end
        image(background)=nan;
    end


    function doHists(images,maxPixel,desc)
        bins=0:maxPixel;
        for i=1:length(images)
            pic=images{i}(:);
            pic=pic(~isnan(pic));
            counts(i,:)=hist(pic(:),bins);
            names{i}=sprintf('image %d',i);
        end

        plot(bins,counts')
        legend(names)
        title(desc)
        xlabel('pixel value')
        ylabel('frequency')
    end

    function image=alignImages(images,screenSize,insetColor,backgroundColor)

        for i=1:length(images)
            [heights(i) widths(i)]=size(images{i});
        end

        [shortestFirst order]=sort(heights);
        tallest = heights(order(end));

        [thinestFirst order]=sort(widths);
        widest=widths(order(end));

        if isempty(screenSize)
            screenSize=[tallest length(images)*widest];
        end

        tallest
        widest

        backgroundSize=[screenSize(1),floor(screenSize(2)/length(images))];
        image=[];
        for i=1:length(images)
            pic=centerImageInBackground(images{i},insetColor,[tallest widest]);
            size(pic)
            backgroundSize
            image=[image centerImageInBackground(pic,backgroundColor,backgroundSize)];

            %subplot(length(images)+1,1,i)
            %hist(double(pic(:)),0:255)
        end
        %subplot(length(images)+1,1,length(images)+1)
        %hist(double(image(:)),0:255)
        %pause
    end


    function images=equalizeHistograms(images,maxPixel)
        method = 'edf';

        %everything here is too low contrast -- here's a better idea:
        %find the distributions of the images and crosscorrelate them to align them
        %(can't just average cuz you'd get a multimodal thing)
        %then scale the result to max contrast

        %actually, uniform is OK

        dist='uniform';
        allData=[];
        for i=1:length(images)
            if ~isempty(images{i})
                imdata{i}=round(images{i}(:));
                [imVals{i} inds{i}]=sort(imdata{i});
                imdata{i}=imdata{i}(~isnan(imdata{i}));
                counts(i)=length(imdata{i});
                [means(i) contrasts(i)]=normfit(imdata{i});
                allData=[allData imdata{i}'];
            end
        end

        for i=1:length(images)
            if ~isempty(images{i})
                vals=.5+(0:maxPixel);
                switch dist
                    case 'gaussian'
                        targetDist=round(diff([0 counts(i)*normcdf(vals,maxPixel/2,mean(contrasts))]));
                        targetDist(end)=targetDist(1); %account for the (symmetric) mass in the tails...

                        %this method wasn't integrting properly
                        %targetDist=round(counts(i)*normpdf(vals,maxPixel/2,mean(contrasts)));
                        %targetDist([1 end])=round(counts(i)*normcdf(0,maxPixel/2,mean(contrasts))); %account for the (symmetric) mass in the tails...

                        %[sum(targetDist) counts(i)]

                    case 'gamma'
                        g=gamfit(allData);
                        targetDist=round(diff([0 counts(i)*gamcdf(vals,g(1),g(2))]));
                        targetDist(end)=targetDist(end)+counts(i)-sum(targetDist); %clip the top
                    case 'uniform'
                        targetDist=round(repmat(counts(i)/length(vals),1,length(vals)));
                        targetDist(end)=targetDist(end)+counts(i)-sum(targetDist); %account for rounding error

                        counts(i)
                        sum(targetDist)

                    otherwise
                        error('bad dist')
                end


                switch method
                    case 'ipt'
                        %would like to use histeq in image processing toolbox -- probably faster
                        %BUT it cannot ignore the background (no nan or alpha input) and doesn't guarantee an exact histogram match
                        %this demo code ignores targetDist shape -- converts to uniform dist (gives higher contrast)

                        images{i}=uint8(images{i}); %removes nans, histeq doesn't seem to like double input
                        images{i} = histeq(images{i}, repmat(floor(counts(i)/length(targetDist)),1,length(targetDist)));
                        images{i}=double(images{i});

                    case 'edf'

                        temp=nan*zeros(size(images{i}));

                        uniques=unique(imVals{i});
                        uniques=uniques(~isnan(uniques));
                        for valNum=1:length(uniques)
                            valNum
                            scrambleInds=find(imVals{i}==uniques(valNum));
                            [garbage scramble]=sort(rand(1,length(scrambleInds)));
                            targets=inds{i}(scrambleInds);
                            inds{i}(scrambleInds)=targets(scramble);
                        end

                        currVal=1;
                        for valNum=1:length(vals)
                            temp(inds{i}(currVal:min(counts(i),currVal+targetDist(valNum)-1)))=vals(valNum);
                            currVal=currVal+targetDist(valNum);
                        end
                        images{i}=temp;

                    otherwise
                        error('bad method')
                end
            end
        end
    end

    function image=centerImageInBackground(im,backgroundColor,sz)

        if(any(sz<size(im)))
            sz
            size(im)
            error('supplied screen size not big enough')
        end

        im(isnan(im))=backgroundColor;
        [height width]=size(im);
        heightDiff=sz(1)-height;
        widthDiff=sz(2)-width;
        topBuffer=floor(heightDiff/2);
        bottomBuffer=ceil(heightDiff/2);
        leftBuffer=floor(widthDiff/2);
        rightBuffer=ceil(widthDiff/2);
        topBuffer=backgroundColor*uint8(ones(topBuffer,leftBuffer+width+rightBuffer));
        bottomBuffer=backgroundColor*uint8(ones(bottomBuffer,leftBuffer+width+rightBuffer));

        % sz
        %
        % size(topBuffer)
        % size(backgroundColor*uint8(ones(height,leftBuffer)))
        % size(im)
        % size(backgroundColor*uint8(ones(height,rightBuffer)))
        % size(bottomBuffer)

        image=[topBuffer; backgroundColor*uint8(ones(height,leftBuffer)) uint8(im) backgroundColor*uint8(ones(height,rightBuffer)); bottomBuffer];
    end

%my algorithm is cool, but matlab's is faster :(
%images{i}=replaceContiguousPixelsAndCrop(images{i},[1 1; 1 size(images{i},2); size(images{i},1) size(images{i},2); size(images{i},1) 1],nan);
    function image=replaceContiguousPixelsAndCrop(image,pts,replace)
        while ~isempty(pts)
            ptInds=sub2ind(size(image),pts(:,1),pts(:,2));
            targetColor=unique(image(ptInds));
            if ~isscalar(targetColor)
                error('pts aren''t all same color')
            end
            image(ptInds)=replace;
            newpts=[];
            for i=1:size(pts,1)
                pt=pts(i,:);
                neighbors=[-1 0;1 0;0 1;0 -1];
                neighbors=repmat(pt,size(neighbors,1),1)+neighbors;
                newpts=[newpts;neighbors(all((neighbors>0 & neighbors<=repmat(size(image),size(neighbors,1),1))'),:)];
                newpts=unique(newpts,'rows');
            end
            pts=newpts(image(sub2ind(size(image),newpts(:,1),newpts(:,2)))==targetColor,:);
        end
        boundaries=image~=replace;
        sides=sum(boundaries);
        topAndBottom=sum(boundaries');
        image=image(min(find(topAndBottom)):max(find(topAndBottom)),min(find(sides)):max(find(sides)));
    end

