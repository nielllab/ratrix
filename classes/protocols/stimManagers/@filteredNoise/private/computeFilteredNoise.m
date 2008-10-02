function stimulus=computeFilteredNoise(stimulus,hz)

% in.orientations               cell of orientations, one for each correct answer port, in radians, 0 is vertical, positive is clockwise  ex: {-pi/4 [] pi/4}
% in.locationDistributions      cell of 2-d densities, one for each correct answer port, will be normalized to stim area  ex: {[2d] [] [2d]}
%
% in.background                 0-1, normalized
% in.contrast                   std dev in normalized luminance units (just counting patch, before mask application), values will saturate
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area
%
% in.patchHeight                0-1, normalized to diagonal of stim area
% in.patchWidth                 0-1, normalized to diagonal of stim area
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window
%
% in.maxWidth
% in.maxHeight
% in.scaleFactor
% in.interTrialLuminance

sz=[50 50]; %height, width

scale=floor(stimulus.kernelSize*sqrt(sum(sz.^2)));
if rem(scale,2)==0
    scale=scale+1; %want nearest odd integer
end

bound=norminv(stimulus.bound,0,1); %only appropriate cuz marginal of mvnorm along one of its axes is norm with same variance as that eigenvector's eigenvalue

for i=1:length(stimulus.orientations)
    if ~isempty(stimulus.orientations{i})

        %a multivariate gaussian's equidensity contours are ellipsoids
        %principle axes given by the eigenvectors of its covariance matrix
        %the eigenvalues are the squared relative lengths
        %sigma = ULU' where U's columns are unit eigenvectors (a rotation matrix) and L is a diagonal matrix of eigenvalues
        axes=eye(2); %note that interpretation depends on axis xy vs. axis ij
        rot=[cos(stimulus.orientations{i}) -sin(stimulus.orientations{i}); sin(stimulus.orientations{i}) cos(stimulus.orientations{i})];
        axes=rot*axes;
        sigma=axes*diag([stimulus.ratio 1].^2)*axes';

        [a b]=meshgrid(linspace(-bound,bound,scale));
        kernel=reshape(mvnpdf([a(:) b(:)],0,sigma),scale,scale);
        kernel=stimulus.filterStrength*kernel/max(kernel(:));

        kernel(ceil(scale/2),ceil(scale/2))=1; %so filterStrength=0 means identity
        kernel=kernel/sqrt(sum(kernel(:).^2));  %to preserve contrast
        %filtering effectively summed a bunch of independent gaussians with variances determined by the kernel entries
        %if X ~ N(0,a) and Y ~ N(0,b), then X+Y ~ N(0,a+b) and cX ~ N(0,ac^2)
        %must be a deep reason this is same as pythagorean

        %stim=stim/sqrt(sum(kernel(:).^2)); %alternative to above, but cooler to have self correcting kernel operator

        frames=round(stimulus.loopDuration*hz);
        dur=round(stimulus.kernelDuration*hz);

        noise=randn([sz frames]);
        t=normpdf(linspace(-bound,bound,dur),0,1);

        for j=1:dur
            k(:,:,j)=kernel*t(j);
        end

        k=k/sqrt(sum(k(:).^2));
        %stim=convn(noise,k,'same'); %slower than imfilter
        tic
        stim=imfilter(noise,k,'circular'); %allows looping, does it keep edges nice?
        toc

        stimulus.cache{i}=stim;
        
%         i
%         stimulus.orientations{i}
%         size(stim)
%         imagesc(stim(:,:,round(size(stim,3)/2)))
    end
end