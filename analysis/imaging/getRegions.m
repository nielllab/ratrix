afiles = {'C:\data\imaging\022314 G62B.7-LT HvV_center Behavior\022314 G62B.7-LT passive veiwing\G62B.7-LT_run2_topoX_15ms\topox_dfofmaps.mat' ...
        'C:\data\imaging\022314 G62B.7-LT HvV_center Behavior\022314 G62B.7-LT passive veiwing\G62B.7-LT_run3_topoY_15ms\g62b4ln_topoymaps.mat' ...
        'C:\data\imaging\022314 G62B.7-LT HvV_center Behavior\022314 G62B.7-LT passive veiwing\G62B.7-LT_run1_step_binary_15ms\stepbinarymaps.mat'}
expname = '022314 G62B.7-LT';
    
    
    afiles = {'C:\data\imaging\022514 G62B.7-LT HvV_center Behavior\topoXmaps.mat' ...
        'C:\data\imaging\022514 G62B.7-LT HvV_center Behavior\topoYmaps.mat'}
expname =   '022514 G62B.7-LT';
% 
% afiles = {'C:\data\imaging\042214 j140 gc6 in lp\J140_run3_topoY_50ms_exp_landscape_fs2.8maps.mat',...
%     'C:\data\imaging\042214 j140 gc6 in lp\J140_run2_topoX_50ms_exp_landscape_fs2.8maps.mat'};
% expname = '042214 j140 lp';

% afiles = {'C:\data\imaging\022814 G62B.3-RT HvV Behavior\topoXmaps.mat' ...
%     'C:\data\imaging\022814 G62B.3-RT HvV Behavior\topoYmaps.mat'}
% expname ='022814 G62B.3';

% afiles = {'C:\data\imaging\030114 G62B.5-LT GTS Behavior (Fstop 8)\topoXf8maps.mat' ...
% 'C:\data\imaging\030114 G62B.5-LT GTS Behavior (Fstop 8)\topoYf8maps.mat'}
% expname = '030114 G62B.5-LT';

afiles = {'C:\data\imaging\042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run1_topox_fstop5.6_exp50msmaps.mat' ...
     'C:\data\imaging\042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run2_topoy_fstop5.6_exp50msmaps.mat'}
 expname = '042414g62hltt_vert';
 
 afiles = {'C:\data\imaging\042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run6_topoy_landscape_fstop5.6_exp50msmaps.mat' ...
        'C:\data\imaging\042414g62h1tt passive mapping\042414 g62h1tt maps\G62H1TT_run5_topox_landscape_fstop5.6_exp50msmaps.mat'}
 expname = '042414g62hltt_horiz';
    maptype = {'topox','topoy','stepbinary'};

    
    close all

for m = 1:2
load(afiles{m})
    
map = map{3};
map_all{m} = map;
ph = angle(map);
amp = abs(map);

figure
imshow(polarMap(map));
title(sprintf('polarmap %s',maptype{m}));

[dx dy] = gradient(ph);
grad = dx + sqrt(-1)*dy;
grad_amp = abs(grad);

dx(grad_amp>1)=0; dy(grad_amp>1)=0;
dx = medfilt2(dx,[5 5]); dy = medfilt2(dy, [5 5]);

grad = dx + sqrt(-1)*dy;

figure
plot(dx.*amp./abs(grad),dy.*amp./abs(grad),'.')
title(sprintf('normalized gradient %s',maptype{m}));


gradmap = grad.*amp./abs(grad);
gradmap(isnan(gradmap))=0;

figure
imshow(polarMap(gradmap));
title(sprintf('gradient %s',maptype{m}));

grad_all{m} = grad; amp_all{m}=amp;  norm_grad{m} = grad./abs(grad);

figure
imshow(polarMap(gradmap));
hold on
quiver(10*real(norm_grad{m}),10*imag(norm_grad{m}))

end

figure
plot(angle(norm_grad{1}).*(amp_all{1}>0.002),angle(norm_grad{2}).*(amp_all{2}>0.002),'.')
title('angle 1 vs angle 2 normalized by step binary');

ampscale = amp_all{2};
ampscale = ampscale/0.0075;
ampscale(ampscale>1)=1;

merge = zeros(size(map,1),size(map,2),3);

merge(:,:,1) = ampscale.*(0.66*(real(norm_grad{1}) + 1)*0.5 + 0.33*(imag(norm_grad{2}) + 1)*0.5) ;
merge(:,:,2) = ampscale.*((imag(norm_grad{1}) + 1)*0.5 );
merge(:,:,3) = ampscale.*(0.66*(real(norm_grad{2}) + 1)*0.5+ 0.33*(imag(norm_grad{2}) + 1)*0.5);

merge(:,:,1) = ampscale.*(0.75*(real(norm_grad{1}) + 1)*0.5 + 0.25*(imag(norm_grad{2}) + 1)*0.5) ;
merge(:,:,2) = ampscale.*(0.75*(imag(norm_grad{1}) + 1)*0.5 + 0.25*(imag(norm_grad{2}) + 1)*0.5);
merge(:,:,3) = ampscale.*(0.75*(real(norm_grad{2}) + 1)*0.5+ 0.25*(imag(norm_grad{2}) + 1)*0.5);

% merge(:,:,1) = ampscale.*(real(norm_grad{1}) + 1)*0.5 ;
% merge(:,:,2) = ampscale.*(imag(norm_grad{1}) + 1)*0.5;
% merge(:,:,3) = ampscale.*(real(norm_grad{2}) + 1)*0.5;

figure
imshow(merge)
title('composite of gradient components')



figure
imagesc(angle(map_all{1})); colormap(hsv); colorbar

figure
imagesc(angle(map_all{2})); colormap(hsv);colorbar

d1 = (angle(map_all{1})- -2.8);
d1(d1>pi) = d1(d1>pi)-2*pi;

d2 = (angle(map_all{2})- -2.8);
d2(d2>pi) = d2(d2>pi)-2*pi;


ecc = sqrt(d1.^2 + d2.^2);
figure
imagesc(ecc,[ 0 2]);
title('eccentricity plot')

figure
subplot(2,2,1)
imshow(polarMap(map_all{1}));
subplot(2,2,2)
imshow(polarMap(map_all{2}));
subplot(2,2,3)
imshow(merge)
subplot(2,2,4)
imagesc(ecc,[ 0 2]); axis equal

for m = 1:2
    figure
imshow((merge));
hold on
quiver(10*real(norm_grad{m}),10*imag(norm_grad{m}),'w')
end


figure
imshow(zeros(size(merge)));
hold on
quiver(10*real(norm_grad{1}),10*imag(norm_grad{1}),'r')

quiver(10*real(norm_grad{2}),10*imag(norm_grad{2}),'g')

dx=3;
rangex = dx:dx:size(norm_grad{1},1);
rangey = dx:dx:size(norm_grad{1},1);
for m = 1:2
    figure
imshow((merge));
hold on
quiver(rangex, rangey, 10*real(norm_grad{m}(rangex,rangey)),10*imag(norm_grad{m}(rangex,rangey)),'w')
if m==1
    title([expname 'elevation']);
else
    title([expname 'azimuth']);
end
xlim([40 130]);
ylim([30 120]);
end



for m= 1:2
figure
imshow(polarMap(map_all{m},90));
hold on
quiver(rangex, rangey, 10*real(norm_grad{m}(rangex,rangey)),10*imag(norm_grad{m}(rangex,rangey)),'w')
% xlim([20 150]);
% ylim([10 140]);
end

figure
imshow(ones(size(merge)));
hold on
quiver(rangex, rangey, 10*real(norm_grad{1}(rangex,rangey)),10*imag(norm_grad{1}(rangex,rangey)),'r')
quiver(rangex, rangey, 10*real(norm_grad{2}(rangex,rangey)),10*imag(norm_grad{2}(rangex,rangey)),'b')
xlim([30 110]);
ylim([10 90]);

clear div
for m= 1:2
    div{m} = divergence(real(norm_grad{m}),imag(norm_grad{m}));
figure
imagesc(abs(div{m}),[0 1]);
end
figure
imagesc(abs(div{1})+abs(div{2}),[0 1.5]);
borders = abs(div{1})+abs(div{2});

for m= 1:2
figure
imshow(polarMap(map_all{m},90));
hold on
h=imagesc(borders,[0 1]);
transp = borders>0.3;
set(h,'AlphaData',transp);
 xlim([20 150]);
 ylim([10 140]);
end

save([expname 'div.mat'],'div');

[f p] =uigetfile('*.mat','map file');
load(fullfile(p,f));

figure
imshow(polarMap(map{3},95));
 xlim([20 150]);
 ylim([10 140]);

 
figure
imshow(polarMap(map{3},95));
hold on
h=imshow(borders>0.3);
transp = borders>0.3;
set(h,'AlphaData',transp*0.5);
 xlim([20 150]);
 ylim([10 140]);

