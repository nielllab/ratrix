%%% load in NLW octo data, and select regions for subsequent analysis
%%% cmn 2019

close all
clear all

[f p] = uigetfile('analyzed data','*.mat');
load(fullfile(p,f),'meanGreenImg','xpts','ypts');

nr = input('number of regions : ');

figure
imshow(meanGreenImg); hold on;
col = 'rgbcmy';
region = zeros(size(xpts));
for r = 1:nr;
    done = 0;
    n=0;
    while ~done
        [x y b] = ginput(1);
           if b ==3
               done=1
           else
               n=n+1;
               xb{r}(n) = x;
               yb{r}(n) = y;
               plot(xb{r},yb{r},'o','Color',col(r));
               plot(xb{r},yb{r},'Color',col(r));
           end
    end
    if n>0;
        xb{r}(n+1) = xb{r}(1); yb{r}(n+1) = yb{r}(1);
        region(inpolygon(xpts,ypts,xb{r},yb{r}))=r;
    end
end

figure
imshow(meanGreenImg);
hold on;
for r = 1:nr;
    plot(xpts(region==r),ypts(region==r),'o','Color',col(r));
end

save(fullfile(p,f),'xb','yb','region','-append');