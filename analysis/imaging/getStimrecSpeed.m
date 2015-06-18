function sp = getStimrecSpeed(framedt);
[f p] = uigetfile('*.mat','stimrec');
load(fullfile(p,f));
framedt = 0.25;

    mouseT = stimRec.ts- stimRec.ts(1)+0.0001; %%% first is sometimes off
    figure
    plot(diff(mouseT));
    
    figure
    plot(mouseT - stimRec.f/60)
    ylim([-0.5 0.5])
    
    dt = diff(mouseT);
    use = [1<0; dt>0];
    mouseT=mouseT(use);
    
    posx = cumsum(stimRec.pos(use,1)-900);
    posy = cumsum(stimRec.pos(use,2)-500);
    frameT = framedt:framedt:floor(mouseT(end));
    vx = diff(interp1(mouseT,posx,frameT));
    vy = diff(interp1(mouseT,posy,frameT));
    vx(end+1)=0; vy(end+1)=0;
    
    figure
    plot(vx); hold on; plot(vy,'g');
    sp = sqrt(vx.^2 + vy.^2);
    figure
    plot(sp)
    hold on 