n=1;
files(n).subj = 'G62h1tt';
files(n).expt = '052214';
files(n).dir = 'C:\data\imaging\052214 Gcamp6 running area\G62h1-TT';
files(n).region = 'running area';
files(n).site=1;
files(n).zoom=1;
files(n).images = 'running area - darkness stim - zoom1004.tif';
files(n).stimobj = 'running area - darkness stim - zoom1004_stim_obj.mat';
files(n).stim = 'darkness';
files(n).notes= '';

n=n+1;
files(n).subj = 'G62h1tt';
files(n).expt = '052214';
files(n).dir = 'C:\data\imaging\052214 Gcamp6 running area\G62h1-TT';
files(n).region = 'running area';
files(n).site=1;
files(n).zoom=2;
files(n).images = 'running area - darkness stim - zoom2005.tif';
files(n).stimobj = 'running area - darkness stim - zoom2005_stim_obj.mat';
files(n).stim = 'darkness';
files(n).notes= '';

n=n+1;
files(n).subj = 'G62h1tt';
files(n).expt = '052214';
files(n).dir = 'C:\data\imaging\052214 Gcamp6 running area\G62h1-TT';
files(n).region = 'running area';
files(n).site=1;
files(n).zoom=2;
files(n).images = 'running area - step binary stim - zoom2006.tif';
files(n).stimobj = 'running area - step binary stim - zoom2006_stim_obj.mat';
files(n).stim = 'stepbinary';
files(n).notes= '';

n=n+1;
files(n).subj = 'G62h1tt';
files(n).expt = '052214';
files(n).dir = 'C:\data\imaging\052214 Gcamp6 running area\G62h1-TT';
files(n).region = 'running area';
files(n).site=1;
files(n).zoom=1;
files(n).images = 'running area - step binary stim - zoom1007.tif';
files(n).stimobj = 'running area - step binary stim - zoom1007_stim_obj.mat';
files(n).stim = 'stepbinary';
files(n).notes= '';


n=n+1;
files(n).subj = 'G62h1tt';
files(n).expt = '052214';
files(n).dir = '';
files(n).region = 'v1';
files(n).site=1;
files(n).zoom=1;
files(n).images = 'V1 - darkness stim - zoom1008.tif';
files(n).stimobj = '';
files(n).stim = 'darkness';
files(n).notes= '';

n=n+1;
files(n).subj = 'G62h1tt';
files(n).expt = '052214';
files(n).dir = '';
files(n).region = 'v1';
files(n).site=1;
files(n).zoom=1;
files(n).images = 'V1 - step binary stim - zoom1009.tif';
files(n).stimobj = '';
files(n).stim = 'stepbinary';
files(n).notes= '';

n=n+1;
files(n).subj = 'G62h1tt';
files(n).expt = '052214';
files(n).dir = '';
files(n).region = 'v1';
files(n).site=1;
files(n).zoom=1;
files(n).images = 'V1 - step binary stim - zoom2010.tif';
files(n).stimobj = '';
files(n).stim = '';
files(n).notes= '';

n=n+1;
files(n).subj = 'G62h1tt';
files(n).expt = '052214';
files(n).dir = '';
files(n).region = 'v1';
files(n).site=1;
files(n).zoom=1;
files(n).images = 'V1 - darkness stim - zoom2011.tif';
files(n).stimobj = '';
files(n).stim = 'darkness';
files(n).notes= '';

n=n+1;
files(n).subj = '';
files(n).expt = '';
files(n).dir = '';
files(n).region = '';
files(n).site=1;
files(n).zoom=1;
files(n).images = '';
files(n).stimobj = '';
files(n).stim = '';
files(n).notes= '';

n=n+1;
files(n).subj = '';
files(n).expt = '';
files(n).dir = '';
files(n).region = '';
files(n).site=1;
files(n).zoom=1;
files(n).images = '';
files(n).stimobj = '';
files(n).stim = '';
files(n).notes= '';

% n=n+1;
% files(n).subj = '';
% files(n).expt = '';
% files(n).dir = '';
% files(n).region = '';
% files(n).site=1;
% files(n).zoom=1;
% files(n).images = '';
% files(n).stimobj = '';
% files(n).stim = '';
% files(n).notes= '';



use = find(strcmp({files.stim},'darkness'))

% for f = use
%     running2p(fullfile(files(f).dir,files(f).images),fullfile(files(f).dir,files(f).stimobj));
% end
% 
% for f=use
%     r = sbxalign(fullfile(files(f).dir,files(f).images),1:600);
%     figure
% 
%    plot(r.T(:,1));
%     hold on
%     plot(r.T(:,2),'g');
% figure
%     imagesc(r.m{1}); colormap gray; axis equal
% end

use = find(strcmp({files.stim},'stepbinary'))
for f = use
   periodic2p(fullfile(files(f).dir,files(f).images),fullfile(files(f).dir,files(f).stimobj),10);
end

