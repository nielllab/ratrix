
load('G62J4RT topoX rev landscape F11maps.mat')
movieshort = moviedata(:,:,(1:100)*6);
movieshort = imresize(movieshort,0.4,'box');
movieshort = mat2im(movieshort,gray,[0 255]);
movieshort = permute(movieshort,[2 1 3 4]);
movieshort = movieshort(8:end,8:end,:,:);

baseline = prctile(cycle_mov,5,3);
cycle_mov = cycle_mov - repmat(baseline,[1 1 size(cycle_mov,3)]);
lowthresh= prctile(cycle_mov(:),2)*0.75;
upperthresh = prctile(cycle_mov(:),98)*1.5;
cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
cycMov = permute(cycMov,[2 1 3 4]);
cycMov= cycMov(end:-1:1,:,:,:);
cycMov(51:size(movieshort,1)+50,21:size(movieshort,2)+20,:,:) = movieshort;
mov = immovie(permute(cycMov,[1 2 4 3]));
mov=repmat(mov,[1 4]);
vid = VideoWriter('g62j4rt_081414_topoxreverselandscape_fstop11_exp50ms_0001.tif.avi');
% mov = immovie(permute(shiftmov,[1 2 4 3]));
% vid = VideoWriter('bilateralS1.avi');
vid.FrameRate=25;
open(vid);
writeVideo(vid,mov);
close(vid)



movieshort = moviedata(:,:,(1:1000)*6);
movieshort = imresize(movieshort,0.25,'box');
movieshort = mat2im(movieshort,gray,[0 255]);

movieshort = moviedata(:,:,(1:300)*6);
movieshort = imresize(movieshort,0.4,'box');
movieshort = mat2im(movieshort,gray,[0 255]);
movieshort = permute(movieshort,[2 1 3 4]);
movieshort = movieshort(8:end,8:end,:,:);



%dfshort = (double(dfof_bg(:,:,950:1249))); % for g62h4rt landscape 050114
dfshort = (double(dfof_bg(:,:,201:500))); 
dfshort = imresize(dfshort,1,'method','box');
baseline = prctile(dfshort,3,3);
cycle_mov = dfshort - repmat(baseline,[1 1 size(dfshort,3)]);
lowthresh= prctile(cycle_mov(:),2);
upperthresh = prctile(cycle_mov(:),98)*1.25;
cycMov= mat2im(cycle_mov,gray,[lowthresh upperthresh]);
cycMov = permute(cycMov,[2 1 3 4]);
cycMov= cycMov(end:-1:1,:,:,:);
cycMov(51:size(movieshort,1)+50,21:size(movieshort,2)+20,:,:) = movieshort;
mov = immovie(permute(cycMov,[1 2 4 3]));
mov = repmat(mov,[1 2])
vid = VideoWriter('g62j4rt_081414_topoxreverselandscape_withstim RAW.avi');
% mov = immovie(permute(shiftmov,[1 2 4 3]));
% vid = VideoWriter('bilateralS1.avi');
vid.FrameRate=25;
open(vid);
writeVideo(vid,mov);
close(vid)