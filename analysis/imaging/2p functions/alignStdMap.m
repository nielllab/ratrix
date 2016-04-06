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
load(filename{1},'greenframe','dfofInterp');
greenframe=double(greenframe);
toc
figure; set(gcf, 'Name',sessionName{1});
refFrame = greenframe;

display('std dev')
tic
stdref = std(dfofInterp(:,:,4:4:end),[],3); %%% std deviation map over all sessions (initialized for ref map
toc
subplot(1,2,2);
imagesc(stdref,[0 prctile(stdref(:),99.5)]); colormap jet; axis equal

refFrame = imresize(refFrame,size(stdref)); %%% b/c dfof data is often compressed
subplot(1,2,1);
imagesc(refFrame,[0 prctile(refFrame(:),99)]); colormap gray; axis equal; freezeColors;
ref = refFrame-mean(refFrame(:));

drawnow


for n = 2:nfiles
    clear greenframe
    display(sprintf('loading file %d',n))
    tic
    load(filename{n},'greenframe','dfofInterp');
    toc
    greenframe=double(greenframe);
    stdframe = std(dfofInterp(:,:,4:4:end),[],3);
    greenframe = imresize(greenframe,size(stdref));
    
    figure; set(gcf,'Name',sessionName{n});
    subplot(2,2,1)
    imagesc(stdframe,[0 0.5]); freezeColors
    
    %%% do cross-correlation alignment based on green (mean raw fluorescence) image
    gr = greenframe-mean(greenframe(:));
    for dx=-20:20;
        for dy = -20:20;
            cs = circshift(ref,[dx dy]);
            xc(dx+21,dy+21)=sum(sum(cs(20:end-20,20:end-20).*gr(20:end-20,20:end-20)));
        end
    end
    subplot(2,2,2);
    imagesc(xc); title('alignment xc'); freezeColors
    [m ind] = max(xc(:));
    [shiftx shifty] = ind2sub([41 41],ind);
    shiftx=shiftx-21
    shifty=shifty-21
    
    greenframe = circshift(greenframe,-[shiftx shifty]);
    im(:,:,1)=0.8*refFrame/prctile(refFrame(:),98);
    im(:,:,2) = 0.8*greenframe/prctile(greenframe(:),98);
    im(:,:,3)=0;

    
    subplot(2,2,4);
    imagesc(greenframe,[0 prctile(greenframe(:),99)]*1.2); axis equal; colormap gray
    
       figure     
    imshow(im)
    title('overlay with ref')
    stdref = max(stdref,circshift(stdframe,-[shiftx shifty]));
    
    drawnow
end


figure
imagesc(stdref); axis equal; colormap jet
%%% select potential cell bodies
display('selecting points')

[x y] = getCellPts(stdref,refFrame);




