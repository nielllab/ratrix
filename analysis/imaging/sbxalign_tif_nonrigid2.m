function r = sbxalign_tif_nonrigid2(ImgSeq, idx)
%%%written by dario ringach, adapted for tif by cmn
%%% http://scanbox.wordpress.com/2014/03/20/recursive-image-alignment-and-statistics/
%%% https://scanbox.org/2016/06/30/non-rigid-image-alignment-in-twenty-lines-of-matlab/

if(length(idx)==1)
    
    A = ImgSeq(:,:,idx(1)); 
    A = edgetaper(A,fspecial('gaussian',10,2));
    
    r.m{1} = A; % mean
    r.T = {zeros([size(A) 2])}; % no translation (identity)
    r.n = 1; % # of frames
    
elseif (length(idx)==2)
    A = ImgSeq(:,:,idx(1));  
    B = ImgSeq(:,:,idx(2)); 
    [D,Ar] = imregdemons(A,B,[64 32 16 8],'AccumulatedFieldSmoothing',3,'PyramidLevels',4,'DisplayWaitBar',false);

    r.m{1} = (Ar/2+B/2);
    r.T = {D zeros([size(A) 2])};
    r.n = 2;
else
    % split into two groups
    idx0 = idx(1:floor(end/2)); 
    idx1 = idx(floor(end/2)+1 : end);
    
    % align each group
    r0 = sbxalign_tif_nonrigid2(ImgSeq,idx0); 
    r1 = sbxalign_tif_nonrigid2(ImgSeq,idx1);
    
    [D,Ar] = imregdemons(r0.m{1},r1.m{1},[64 32 16 8],'AccumulatedFieldSmoothing',3,'PyramidLevels',4,'DisplayWaitBar',false);

    r.m{1} = (Ar/2 + r1.m{1}/2);
    % concatenate distortions
    r0.T = cellfun(@(x) (x+D),r0.T,'UniformOutput',false); 
    r.T = [r0.T r1.T];
    
end

