function [dfofInterp, im_dt, Grn95Percentile] = get2pdata(fname,dt, Opt)

if Opt.SaveFigs
    psfile = Opt.psfile;
end
% Display Movies for Non-aligned image sequences for both channels & save
% the movie if it does not exist already
if Opt.MakeMov
    MakeMovieFromTiff(fname);
end

% Performs Image registration for both channels
[Aligned_Seq, mv] = readAlign2p(fname,Opt);

%Replace Inf Values with NaN
for iFrame = 1:size(imgAll,3)
    frm = imgAll(:,:,iFrame);
    frm(isinf(frm(:))) = NaN;
    imgAll(:,:,iFrame) = frm;
end

%Get Info
Img_Info = imfinfo(fname);
trash = evalc(Img_Info(1).ImageDescription);
framerate = state.acq.frameRate;
im_dt = 1/framerate;

%Calculate the 95% of the green images
Grn95Percentile = squeeze(prctile(imgAll,95,3));

%%
disp('Doing percentile for delta-f/f calculations');
nframes = size(Aligned_Seq,3);

%Calculate the 10th percentile of a representative sample
m10 = prctile(Aligned_Seq(:,:,40:40:end),10,3);

%Display the figure
figure
imagesc(m10);
title('Mean 10th percentile')
colormap(gray)
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

dfof = zeros(size(Aligned_Seq));

for iFrame = 1:nframes
    dfof(:,:,iFrame)=(Aligned_Seq(:,:,iFrame)-m10)./m10;
end

%Interpolate to desired frame rate if different than acquisition rate
if im_dt ~= dt
    dfofInterp = interp1(0:im_dt:(nframes-1)*im_dt,shiftdim(dfof,2),0:dt:(nframes-1)*im_dt);
    dfofInterp = shiftdim(dfofInterp,1);
else
    dfofInterp = dfof;
end