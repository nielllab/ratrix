function resp = fourPhaseOverlay(expfile,pathname,outpathname, exptype)

opengl software

expname = [expfile.subj expfile.expt];
isfield(expfile,exptype)
~isempty(getfield(expfile, exptype))

if isfield(expfile,exptype) &&  ~isempty(getfield(expfile, exptype))
    load([pathname getfield(expfile,exptype)],'cycMap'); %%% behavior

    clear resp
    
    if size(cycMap,3)~=101 & strcmp(exptype,'grating')
        sprintf('couldnt do gratings size ~= 101 %s',[expfile.subj expfile.expt])
        resp=[];
        return;
    end
    
    
    base = mean(cycMap(:,:,[20:24 45:49 70:74 95:99]),3);
    for i = 1:4
        resp(:,:,i) = mean(cycMap(:,:,(1:10)+(i-1)*25),3)-base;
    end
    meanresp = mean(resp,3);
    amp = meanresp/0.005;
    amp(amp>1)=1;
    transp = amp>0.25;
    

    transp=1;
    amp = repmat(amp,[1 1 3]);
    figure
    
    subplot(2,2,1)
   % imshow(merge);
   imagesc(meanresp,[0 0.005]);
    title([expname ' ' exptype]);
    
    subplot(2,2,2);

    im =amp.* mat2im((resp(:,:,1)-resp(:,:,4))./(resp(:,:,4)+resp(:,:,1)),jet,[-1 1]);
    imshow(im)
    title('1st vs last')
    
    subplot(2,2,3);
   
    im =amp.* mat2im((resp(:,:,1) + resp(:,:,2)-resp(:,:,3)-resp(:,:,4))./(4*meanresp),jet,[-1 1]);
imshow(im)
    title('1st half vs second half')
    
    subplot(2,2,4);
   
    im =amp.* mat2im((resp(:,:,1) + resp(:,:,3)-resp(:,:,2)-resp(:,:,4))./(4*meanresp),jet,[-1 1]);
    h = imshow(im);
    title('1+3 vs 2 + 4')
else
    resp=[];
end

end

