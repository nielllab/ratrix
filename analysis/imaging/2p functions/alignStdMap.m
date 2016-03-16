%%% Aligns images across multiple sessions
%%% and selects points for cell body extraction
%%%
%%% Note - run appropriate stim-specific programs first
%%% to create session files

nfiles = input('# of files : ')
for i = 1:nfiles
    [f p] = uigetfile('*.mat','session file');
    filename{i} = fullfile(p,f);
    sessionName{i}=f;
end

%%% load first file, which will serve as reference for alignment
load(filename{1});
figure; set(gcf, 'Name',sessionName{1});
refFrame = greenframe;
subplot(1,2,1);
imagesc(refFrame,[0 prctile(refFrame(:),99)]); colormap gray
ref = refFrame-mean(refFrame(:));
stdref = std(dfofInterp,[],3); %%% std deviation map over all sessions (initialized for ref map
subplot(1,2,2);
imagesc(stdref,[0 prctile(stdref(:),99.5)])

for n = 2:nfiles
    clear greenframe
    load(filename{n});
    stdframe = std(dfofInterp,[],3);
    figure; set(gcf,'Name',sessionName{n});
    subplot(2,2,1)
    imagesc(stdframe,[0 0.5])
    
    %%% do cross-correlation alignment based on green (mean raw fluorescence) image
    gr = greenframe-mean(greenframe(:));
    for dx=-20:20;
        for dy = -20:20;
            cs = circshift(ref,[dx dy]);
            xc(dx+21,dy+21)=sum(sum(cs(20:end-20,20:end-20).*gr(20:end-20,20:end-20)));
        end
    end
    subplot(2,2,2);
    imagesc(xc); title('alignement xc')
    [m ind] = max(xc(:));
    [shiftx shifty] = ind2sub([41 41],ind);
    shiftx=shiftx-21;
    shifty=shifty-21;
    
    greenframe = circshift(greenframe,-[shiftx shifty]);
    im(:,:,1)=0.8*refFrame/prctile(refFrame(:),95);
    im(:,:,2) = 0.8*greenframe/prctile(greenframe(:),95);
    im(:,:,3)=0;
   subplot(2,2,3);
    imshow(im)
    title('overlay with ref')
    stdref = max(stdref,circshift(stdframe,-[shiftx shifty]));
end
refFrame = imresize(refFrame,size(stdref)); %%% b/c dfof data is often compressed

%%% select potential cell bodies
[x y] = getCellPts(stdref,refFrame);
[f p ] = uiputfile('*mat','generic pts file')
save(fullfile(p,f),'x','y','refFrame','stdref');



