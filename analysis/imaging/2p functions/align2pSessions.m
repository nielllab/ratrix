%%% Aligns images across multiple sessions
%%% and selects points for cell body extraction
%%%
%%% Note - run appropriate stim-specific programs first
%%% to create session files
clear all

nfiles = input('# of files : ')
for i = 1:nfiles
    [f p] = uigetfile('*.mat','session file');
    filename{i} = fullfile(p,f);
    sessionName{i}=f
end

%%% load first file, which will serve as reference for alignment
display('loading first file')
tic
load(filename{1},'greenframe','meanImg');
greenframe=double(greenframe);
toc
figure; set(gcf, 'Name',sessionName{1});
refFrame = greenframe;


refFrame = imresize(refFrame,size(meanImg)); %%% b/c dfof data is often compressed
subplot(1,2,1);
imagesc(refFrame,[0 prctile(refFrame(:),99)]); colormap gray; axis equal; freezeColors;
ref = refFrame-mean(refFrame(:));

drawnow


for n = 2:nfiles
    clear greenframe
    display(sprintf('loading file %d',n))
    tic
    load(filename{n},'greenframe','meanImg');
    toc
    greenframe=double(greenframe);
    greenframe = imresize(greenframe,size(meanImg));
    
    figure; set(gcf,'Name',sessionName{n});
    
    %%% do cross-correlation alignment based on green (mean raw fluorescence) image
    gr = greenframe-mean(greenframe(:));
    range = 30;
    for dx=-range:range
        for dy = -range:range
            cs = circshift(ref,[dx dy]);
            xc(dx+range+1,dy+range+1)=sum(sum(cs(range:end-range,range:end-range).*gr(range:end-range,range:end-range)));
        end
    end
    subplot(2,2,2);
    imagesc(xc); title('alignment xc'); freezeColors
    [m ind] = max(xc(:));
    [shx shy] = ind2sub([2*range+1 2*range+1],ind);
    shiftx(n)=shx-(range+1)
    shifty(n)=shy-(range+1)
    
    greenframe = circshift(greenframe,-[shiftx(n) shifty(n)]);
    im(:,:,1)=0.8*refFrame/prctile(refFrame(:),98);
    im(:,:,2) = 0.8*greenframe/prctile(greenframe(:),98);
    im(:,:,3)=0;

      subplot(2,2,3);
    imagesc(refFrame,[0 prctile(greenframe(:),99)]*1.2); axis equal; colormap gray; axis off; title('ref');
    
    subplot(2,2,4);
    imagesc(greenframe,[0 prctile(greenframe(:),99)]*1.2); axis equal; colormap gray; axis off; title(sessionName{n})
    
     subplot(2,2,1);     
    imshow(im)
    title('overlay with ref')
    
    drawnow
end


