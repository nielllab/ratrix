function stimulus=computeFilteredNoise(stimulus,hz)

sz=stimulus.patchDims; %[height, width]

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

        dur=round(stimulus.kernelDuration*hz);
        t=normpdf(linspace(-bound,bound,dur),0,1);

        for j=1:dur
            k(:,:,j)=kernel*t(j);
        end

        k=k/sqrt(sum(k(:).^2));  %to preserve contrast
        %filtering effectively summed a bunch of independent gaussians with variances determined by the kernel entries
        %if X ~ N(0,a) and Y ~ N(0,b), then X+Y ~ N(0,a+b) and cX ~ N(0,ac^2)
        %must be a deep reason this is same as pythagorean

        frames=round(stimulus.loopDuration*hz);
        noise=randn([sz frames]);

        %         [a b] = hist(noise(:),100);
        %         std(noise(:))

        tic
        %stim=convn(noise,k,'same'); %slower than imfilter
        stim=imfilter(noise,k,'circular'); %allows looping, does it keep edges nice?
        toc

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
end