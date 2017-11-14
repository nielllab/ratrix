function [FrameIndices, FrameBool] = bin_Zplane(Img_Seq, Aligned_Seq, makeFigs)
% This function takes a series of 2p images that have motion artifacts in
% the z-plane and outputs the indices of the largest cluster of frames
% sorted by pdist, linkage, and cluster functions. 
%
% Inputs:
%   Img_Seq: 3D matrix containg the non-aligned image sequence
%   Aligned_Seq: First pass at aligning the frames using rigid compensation
%   idx: Vector of frame indices for use when calling the frames from the
%   tiff file
% Outputs:
%   Indy: Vector of frame indices for a subset of images that presumably
%   are in the same z-plane
if makeFigs
    psfile = 'C:\temp\TempFigs.ps';
end

nframes = size(Aligned_Seq,3);
% Vectorize each frame in the sequence and create a 2D matrix with each row
% corresponding to a frame and each column corresponding to a particular
% pixel in the image
Img_Seq2D = zeros(nframes,size(Aligned_Seq,1)*size(Aligned_Seq,2));
for iFrame = 1:nframes
    % Apply Gaussian Filter to increase SNR
    %iiImg = imfilter(Img_Seq(:,:,iFrame),filt);
    iiImg = Aligned_Seq(:,:,iFrame);
    
    %Add to 2D sequence
    Img_Seq2D(iFrame,:) = iiImg(:);
end

%Correlation values between observations (i.e. per pixel/per image)
D = pdist(Img_Seq2D,'correlation');

%Create hierarchical cluster tree based on D
Z = linkage(D,'ward'); 

%Create figure of hierarchical cluster tree for visualization purposes
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3);
title('Hierarchical Cluster tree of Image Sequence');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%Place remaining code in a while loop so user can try different
%combinations of cluster choices
ReDo = 1;
while ReDo
    %Create Clusters from the hierarchical cluster tree Z
    nclust = input('How many z-plane clusters do you want?: ');
    T = cluster(Z,'maxclust',nclust);
    
    %Determine how many frames each cluster has
    %Display figure of cluster vs frame #
    clust = figure;
    plot(1:1:length(T),T,'-.k','LineWidth',2), hold on
    ColorPalette = lines(nclust);
    ModeT = zeros(nclust,1);
    for iC = 1:nclust
        ModeT(iC,1) = length(find(T == iC));
        fprintf('Cluster %u: %u frames \n',iC, ModeT(iC,1));
        frameIndices = find(T == iC);
        plot(frameIndices,T(frameIndices),'.','Color',ColorPalette(iC,:),'MarkerSize',11), hold on
    end
    title(sprintf('%u Clusters',nclust));
    xlabel('Frame #'); ylabel('Cluster ID');
    %
        
    %Which cluster should be used?
    ImgClust = input('Which cluster of frames do you want to use?: ');
    
    %Calculate clims to use for imagesc
    sm = floor(nframes/4) - 1;
    RedRange = zeros(1,2);
    for iFrame = 1:sm:nframes
        tmp = Img_Seq(:,:,iFrame);
        RedRange(1) = RedRange(1) + prctile(tmp(:),2);
        RedRange(2) = RedRange(2) + prctile(tmp(:),90);
    end
    
    FrameIndices = [];
    NaNIndices = [];
%     clustmov = figure;
%     colormap gray
    for iFrame = 1:nframes
        if T(iFrame) == ImgClust
%             imagesc(Aligned_Seq(:,:,iFrame),RedRange)
%             drawnow
            
            FrameIndices = [FrameIndices, iFrame];
            FrameBool(iFrame,1) = 1;
        else
            NaNIndices = [NaNIndices, iFrame];
            FrameBool(iFrame,1) = 0;
        end
    end
    
    %Give the user the option to reselect which cluster to use
    ReDo = input('Do you want to reselect the # of clusters after watching the movie? (1:yes/0:no): ');
    if ReDo == 1 
        close(clust);
    else 
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
%         close(clustmov);
    end
end
disp('Oiy');
% SortedIndices = [FrameIndices NaNIndices];
% CorrCoeff = zeros(length(SortedIndices));
% for ii = 1:length(SortedIndices)
%     % Downsample from 256x256 to 128x128 to decrease computing time &
%     % decrease noise that may effect correlation measure
%     iiImg = imresize(Aligned_Seq(:,:,SortedIndices(ii)),0.5);
% 
%     % Start at jj = ii because correlation matrix is symmetric
%     for jj = ii:length(SortedIndices)
%         
%         jjImg = imresize(Aligned_Seq(:,:,SortedIndices(jj)),0.5);
%         CorrCoeff(ii,jj) = corr2(iiImg,jjImg);
%         CorrCoeff(jj,ii) = CorrCoeff(ii,jj);
%     end
% end

end

