function avg = fourPhaseAvg(resp,shiftx,shifty,shifttheta,zoom,sz, merge)% %%% overlay behavior on top of topomaps
nb=0; avg=0; clear behav
sz
for f = 1:length(resp)
 

        if ~isempty(resp{f});
       
           try 
               b = shiftImageRotate(resp{f},shiftx(f),shifty(f),shifttheta(f),zoom,sz);
            avg= avg+b;
            nb= nb+1;
           catch
               display('out of range')
           end
        end

end

avg = avg/nb;
resp = avg;

transp = zeros(size(avg));

   meanresp = mean(resp,3);
    amp = meanresp/0.1;
    amp(amp>0.05)=1;
    transp = amp>0.28;
    amp = repmat(amp,[1 1 3]);

figure

    subplot(2,2,1)
    %imshow(merge);
    imagesc(meanresp,[0 0.05])
   axis equal
    
    subplot(2,2,2);
    imshow(merge);
    im =amp.* mat2im((resp(:,:,1)-resp(:,:,4))./(resp(:,:,4)+resp(:,:,1)),jet,[-1 1]);
    hold on
    h = imshow(im);
    set(h,'AlphaData',transp);
    title('1st vs last')
    
    subplot(2,2,3);
    imshow(merge);
    im =amp.* mat2im((resp(:,:,1) + resp(:,:,2)-resp(:,:,3)-resp(:,:,4))./(4*mean(resp,3)),jet,[-1 1]);
    hold on
    h = imshow(im);
    set(h,'AlphaData',transp);
    title('1st half vs second half')
    
    subplot(2,2,4);
    imshow(merge);
    im =amp.* mat2im((resp(:,:,1) + resp(:,:,3)-resp(:,:,2)-resp(:,:,4))./(4*mean(resp,3)),jet,[-1 1]);
    hold on
    h = imshow(im);
    set(h,'AlphaData',transp);
    title('1+3 vs 2 + 4')
    
end