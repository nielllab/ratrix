function fourPhaseOverlay(expfile,pathname,outpathname, exptype)

opengl software

expname = [expfile.subj expfile.expt];
if isfield(expfile,exptype) &&  ~isempty(getfield(expfile, exptype))
    load([pathname getfield(expfile,exptype)],'cycMap'); %%% behavior
    load( [outpathname expfile.subj expfile.expt '_topography.mat']); %%% topography
    clear resp
    
    merge = imresize(merge,[size(cycMap,1) size(cycMap,2)]);
    
    base = mean(cycMap(:,:,[20:24 45:49 70:74 95:99]),3);
    for i = 1:4
        resp(:,:,i) = mean(cycMap(:,:,(1:10)+(i-1)*25),3)-base;
    end
    meanresp = mean(resp,3);
    amp = meanresp/0.05;
    amp(amp>1)=1;
    transp = amp>0.25;
    amp = repmat(amp,[1 1 3]);
    figure
    
    subplot(2,2,1)
    imshow(merge);
    title([expname ' ' exptype]);
    
    subplot(2,2,2);
    imshow(merge);
    im =amp.* mat2im((resp(:,:,1)-resp(:,:,4))./(resp(:,:,4)+resp(:,:,1)),jet,[-1 1]);
    hold on
    h = imshow(im);
    set(h,'AlphaData',transp);
    title('1st vs last')
    
    subplot(2,2,3);
    imshow(merge);
    im =amp.* mat2im((resp(:,:,1) + resp(:,:,2)-resp(:,:,3)-resp(:,:,4))./(4*meanresp),jet,[-1 1]);
    hold on
    h = imshow(im);
    set(h,'AlphaData',transp);
    title('1st half vs second half')
    
    subplot(2,2,4);
    imshow(merge);
    im =amp.* mat2im((resp(:,:,1) + resp(:,:,3)-resp(:,:,2)-resp(:,:,4))./(4*meanresp),jet,[-1 1]);
    hold on
    h = imshow(im);
    set(h,'AlphaData',transp);
    title('1+3 vs 2 + 4')
end

end

