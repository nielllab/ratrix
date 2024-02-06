function sbx2stack_multichan(fname)
%%% reads in a z-stack from scanbox and outputs a multi-channel tif stack
%%% automatically detects # of z planes and channels
%%% averages multiple sections per plane
%%% example usage sbxstack_multichan('stack_000_test')
%%% output tif can be opened in FIJI using Import -> BioFormat
%%% for 1-channel image, output is grayscale stack
%%% for 2-channel image, output is an RGB stack (with empty 3rd color -> a result of Matlab imwrite constraints)
%%% cmn 02-2024

%%% get info from first image
z = sbxread(fname,1,1);
global info;

%%% get some parameters
nch = info.chan.nchan  % number of channels
sched = info.config.knobby.schedule(:,5); % frames where knobby moves to a new plane
nplane = length(sched);  %%% number of planes
nsection = sched(1);  %%% number of sections per plane
sched = [0; sched]; %%% append first plane to start at file 0

for p = 1:nplane
    
    if p/10 == round(p/10)
        sprintf('%d / %d planes done', p, nplane)  %% update status
    end
    
    q = sbxread(fname,sched(p)+1,nsection);  %%% read in all sections at one plane
    mn = median(q,4);   %%% take median average of sections
    if nch==2
        mn(3,:,:)=0;    %%%  if two-color, need to add 3rd channel (for tif format)
        mn = shiftdim(mn,1);  %%% shift color to 3rd dimension
    end
    
    %%% save data into tif!
    if(p==1)
        imwrite(mn,[fname '.tif'],'tif');
    else
        imwrite(mn,[fname '.tif'],'tif','writemode','append');
    end
end