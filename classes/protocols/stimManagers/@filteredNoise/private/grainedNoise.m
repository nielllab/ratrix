function grainedNoise
error('this is just old scratch work')
close all
clc

sz=[50 50]; %height, width

angles=[linspace(0,pi,10) pi/2+pi/10]; %radians, where 0 is vertical, positive is CW
ratio=1/3; %ratio of long axis to short axis length

amp=.025;%.0175; %1; %0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important

scale = .5; %kernel size relative to stim, normalized to diagonal of stim
bound=.99; %edge percentile for long axis of kernel when parallel to window

bits=8;

if ratio<=0 || ratio>1
    error('0<ratio<=1')
end

if scale<=0 || scale>1
    error('0<scale<=1')
end
scale=floor(scale*sqrt(sum(sz.^2)));
if rem(scale,2)==0
    scale=scale+1; %want nearest odd integer
end
scale

if bound<=.5 || bound>=1
    error('.5<=bound<=1')
end
bound=norminv(bound,0,1); %only appropriate cuz marginal of mvnorm along one of its axes is norm with same variance as that eigenvector's eigenvalue

noise=randn(sz);

colormap(gray(2^bits))
for i=1:length(angles)
    %a multivariate gaussian's equidensity contours are ellipsoids
    %principle axes given by the eigenvectors of its covariance matrix
    %the eigenvalues are the squared relative lengths
    %sigma = ULU' where U's columns are unit eigenvectors (a rotation matrix) and L is a diagonal matrix of eigenvalues
    axes=eye(2); %note that interpretation depends on axis xy vs. axis ij
    rot=[cos(angles(i)) -sin(angles(i)); sin(angles(i)) cos(angles(i))];
    axes=rot*axes;
    sigma=axes*diag([ratio 1].^2)*axes';

    [a b]=meshgrid(linspace(-bound,bound,scale));
    kernel=reshape(mvnpdf([a(:) b(:)],0,sigma),scale,scale);
    kernel=amp*kernel/max(kernel(:));

    kernel(ceil(scale/2),ceil(scale/2))=1; %so amp=0 means identity
    kernel=kernel/sqrt(sum(kernel(:).^2));  %to preserve contrast
    %filtering effectively summed a bunch of independent gaussians with variances determined by the kernel entries
    %if X ~ N(0,a) and Y ~ N(0,b), then X+Y ~ N(0,a+b) and cX ~ N(0,ac^2)
    %must be a deep reason this is same as pythagorean

    stim=filter2(kernel,noise);
    %stim=stim/sqrt(sum(kernel(:).^2)); %alternative to above, but cooler to have self correcting kernel operator

    numplots=4;

    axes=rot*diag([ratio 1]);
    subplot(numplots,length(angles),i)
    plot([0 axes(1,1)],[0 axes(2,1)])
    hold on
    plot([0 axes(1,2)],[0 axes(2,2)])
    axis([-1 1 -1 1])
    axis equal
    axis ij

    subplot(numplots,length(angles),length(angles)+i)
    imagesc(kernel);
    axis image

    subplot(numplots,length(angles),2*length(angles)+i)
    image(rescale(stim,2^bits-1));
    axis image

    subplot(numplots,length(angles),3*length(angles)+i)
    [a b]=hist(noise(:),100);
    c=hist(stim(:),b);
    plot(b,[a' c'])
end

if true
    frames=60*2;%100*20;
    dur=15;

    noise=randn([sz frames]);
    t=normpdf(linspace(-bound,bound,dur),0,1);

    plotSTkern=false;
    if plotSTkern
        figure
    end
    colormap(gray(2^bits))
    for i=1:dur
        k(:,:,i)=kernel*t(i);
        if plotSTkern
            subplot(1,dur,i)
            imagesc(k(:,:,i),[0 1])
            axis image
        end
    end
    k=k/sqrt(sum(k(:).^2));
    %stim=convn(noise,k,'same');
    tic
    stim=imfilter(noise,k,'circular'); %allows looping, does it keep edges nice?
    toc
    stim=1+rescale(stim,2^bits-1);

    save('stim.mat','stim');
    
    plotFrames=false;
    if plotFrames
        n=ceil(sqrt(frames+1));
        figure
    end
    map=colormap(gray(2^bits));
    noise=1+rescale(noise,2^bits-1);
    [a b]=hist(noise(:),100);
    reps=10;
    for i=1:frames
        M(frames*(0:reps-1)+i) = im2frame(stim(:,:,i),map);
        if plotFrames
            subplot(ceil((frames+1)/n),n,i)
            image(stim(:,:,i));
            axis image

            subplot(n,n,n^2)
            hold on
            c=hist(stim(:,:,i),b);
            plot(b,c/sum(c))
        end
    end
    if plotFrames
        plot(b,a/sum(a),'r')
    end
    movie2avi(M,'mCinepak','compression','Cinepak','quality',100,'fps',60)
end

function out=rescale(in,mx)
in=in-min(in(:));
out=mx*in/max(in(:));
if any(abs([min(out(:)) max(out(:))]-[0 mx])>.0000001)
    error('scale error')
end