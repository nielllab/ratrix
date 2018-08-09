filt = fspecial('gaussian',[10  10],1);
trialmeanfilt = imfilter(trialmean,filt);

horiz = nanmean(trialmeanfilt(:,:,stimOrder ==1 | stimOrder ==7),3);
vert = nanmean(trialmeanfilt(:,:,stimOrder ==4 | stimOrder ==10),3);
flicker = nanmean(trialmeanfilt(:,:,stimOrder ==4 | stimOrder ==13),3);


figure
imagesc(cycAmp); % amplitude from cycle-average map;

maxdf = 0.05;
hvv = zeros(size(horiz,1),size(horiz,2),3);
hvv(:,:,1) = horiz;
hvv(:,:,2) = vert;
%hvv(:,:,3) = flicker;
hvv = hvv/maxdf;

maxval = max(hvv,[],3);
normalizer = ones(size(maxval));
normalizer(maxval>1) = maxval(maxval>1);  %%% normalize by maximum value, so colors don't saturate if all greater than one

hvv(hvv<0)=0; hvv= hvv./repmat(normalizer,[1 1 3]);

figure
imshow(hvv);
hvImg = hvv;
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

amp = (horiz + flicker + vert)/3;
amp = amp/maxdf;
amp(amp<0)=0; amp(amp>1)=1;

%%% make an "inverse" polar map,that can be used to filter overlay
%%% (although makes it look dark, so not using this; means different map than polar
% invMap = mat2im(cycPhase,1-hsv,[pi/2  (2*pi -pi/4)]);
% invMap = invMap.*repmat(cycAmp,[1 1 3]);
% figure
% imshow(invMap)

%overlay = 1.25*meanGreenImg.*(1- 0.75*invMap);
overlay =0.66* meanGreenImg + 0.33*cycPolarImg;
figure
imshow(overlay)
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

overlayImg = overlay;
