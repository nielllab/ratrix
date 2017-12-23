%rotateCropWF
downsample = 0.5;
for f = 1:length(use)
    filename = sprintf('%s_%s_%s_%s_patchonpatch.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).timing,files(use(f)).inject);
    try
        load(fullfile(outpathname,filename),'rotateCrop')
        sprintf('%s rotateCrop=%d',files(use(f)).subj,rotateCrop==1)
    catch
        sprintf('loading...')
        load(fullfile(pathname,files(use(f)).patchonpatch),'dfof_bg')
        img = imresize(double(dfof_bg),downsample,'method','box');
        if mod(f,2)==1
            stdimg = std(img,[],3);
            satisfied=0;
            while satisfied~=1
                figure;colormap jet
                imagesc(stdimg,[-0.01 0.05])
                title('select back then front')
                [y x] = ginput(2);
                x=round(x);y=round(y);

                theta = -rad2deg(atan((x(1)-x(2))/(y(2)-y(1))));

                stdimg2 = imrotate(stdimg,theta,'crop');
                centOffset = 375; %effective diameter of circle
                buf = 20*downsample; %centers brain since it's slightly longer than wide
                crad = (centOffset*downsample)/2;
                y0 = y(2)-crad+buf*2;x0 = x(1)-buf;
                stdimg2 = stdimg2(x0-crad:x0+crad,y0-crad:y0+crad);
                figure;colormap jet
                imagesc(stdimg2,[-0.01 0.05])
                axis square;axis off

                satisfied = input('satisfied? 1=yes, 0=no: ');
            end
            clear x y

            img = imrotate(img,theta,'crop');
            img = img(x0-crad:x0+crad,y0-crad:y0+crad,:);
            rotateCrop = 1;

            sprintf('saving...')
            try
                save(fullfile(outpathname,filename),'img','downsample','theta','x0','y0','crad','rotateCrop','-append','-v7.3');
            catch
                save(fullfile(outpathname,filename),'img','downsample','theta','x0','y0','crad','rotateCrop','-v7.3');
            end
        else
            sprintf('loading params')
            load(fullfile(outpathname,sprintf('%s_%s_%s_%s_patchonpatch.mat',files(use(f)).expt,files(use(f)).subj,files(use(f-1)).timing,files(use(f)).inject)),...
                'theta','x0','y0','crad');
            img = imrotate(img,theta,'crop');
            img = img(x0-crad:x0+crad,y0-crad:y0+crad,:);
            rotateCrop = 1;

            sprintf('saving...')
            try
                save(fullfile(outpathname,filename),'img','downsample','theta','x0','y0','crad','rotateCrop','-append','-v7.3');
            catch
                save(fullfile(outpathname,filename),'img','downsample','theta','x0','y0','crad','rotateCrop','-v7.3');
            end
        end
    end
    clear rotateCrop
%     [grad{f} amp{f} map_all{f} map{f} merge{f}]= getRegionsCropped(files(use(f)),pathname,outpathname);
    
    
    
    sprintf('finished %d/%d files',f,length(use))
end