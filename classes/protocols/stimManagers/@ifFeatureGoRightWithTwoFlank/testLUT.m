%function [out]=testLUT(s,what);
%tests a lut
%comment out function and run it as a script!

%%
if ~exist('s','var')
    method='linearizedDefault';
    s=getStimManager(setFlankerStimRewardAndTrialManager(getDefaultParameters(ifFeatureGoRightWithTwoFlank)));
    s=fillLUT(s,method,[0 0.5]);
end

if ~exist('what','var') || isempty('what')
   what='sweepGray'; %'sweepGray', getMeanCandelas;  
end

clut=getlut(s);


screenNum=0;
switch what
    case 'getMeanCandelas'
        stim=uint8(ceil((2^8)*repmat(reshape([1:2]/2,[1,1,1,2]),[1,1,3,1]))); % mean screen then white
        frames=500;
        [spyderData daqData, ifi]=generateScreenCalibrationData(screenNum,'CRT',[0 0 1 1],int8(frames),int8(2),clut,stim,[], [],[],'B888',[],true,false,[],[],false);
        out=spyderData(1,2);  
        disp(sprintf('mean  : %3.3f cd/m^2',spyderData(1,2)))
        disp(sprintf('white : %3.3f cd/m^2',spyderData(2,2)))
    case 'sweepGray'
        stim=uint8(repmat(reshape([1:255],[1,1,1,255]),[1,1,3,1])); % no black=0?
        frames=100; % 10 fast,100 normal,5000 is nice
        [spyderData daqData, ifi]=generateScreenCalibrationData(screenNum,'CRT',[0 0 1 1],int8(frames),int8(2),clut,stim,[], [],[],'B888',[],true,false,[],[],false);
        out=spyderData(:,2);  
        in=double(unique(stim));
        inds=[77:179];  % use [1:256] for all, smaller is to test a hypothessis about dim stims
        in=in(inds);
        model=fit(in,out(inds),'poly1');
        y=feval(model,in);
        er=out(inds)-y;
        cancelTest=out(inds(1):128)+flipud(out(128:inds(end)))
        cancelModel=fit([1:length(cancelTest)]',cancelTest,'poly1');
        figure
        subplot(2,2,1); plot(model); hold on; plot(out);
        subplot(2,2,2); plot(cancelModel); hold on; plot(cancelTest);
        subplot(2,2,3); plot(er)
        subplot(2,2,4); plot(er./y)
end

disp(sprintf('calulated Hz: %3.3f',1/ifi))