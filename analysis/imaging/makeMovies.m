baseline = prctile(cycle_mov,5,3);
cycle_mov = cycle_mov - repmat(baseline,[1 1 size(cycle_mov,3)]);
lowthresh= prctile(cycle_mov(:),2)*0.75;
upperthresh = prctile(cycle_mov(:),98)*1.5;
cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
mov = immovie(permute(cycMov,[1 2 4 3]));
vid = VideoWriter('g62j4rt_run2_topoxreverselandscape_fstop11_exp50ms_0001.tif.avi');
% mov = immovie(permute(shiftmov,[1 2 4 3]));
% vid = VideoWriter('bilateralS1.avi');
vid.FrameRate=25;
open(vid);
writeVideo(vid,mov);
close(vid)



dfshort = (double(dfof_bg(:,:,950:1249)));
dfshort = imresize(dfshort,0.5,'method','box');
baseline = prctile(dfshort,3,3);
cycle_mov = dfshort - repmat(baseline,[1 1 size(dfshort,3)]);
lowthresh= prctile(cycle_mov(:),2);
upperthresh = prctile(cycle_mov(:),98)*1.25;
cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
mov = immovie(permute(cycMov,[1 2 4 3]));
vid = VideoWriter('g62h4rt_8mm_landscape_050114_stepbinary_LATER bright sm.avi');
% mov = immovie(permute(shiftmov,[1 2 4 3]));
% vid = VideoWriter('bilateralS1.avi');
vid.FrameRate=25;
open(vid);
writeVideo(vid,mov);
close(vid)