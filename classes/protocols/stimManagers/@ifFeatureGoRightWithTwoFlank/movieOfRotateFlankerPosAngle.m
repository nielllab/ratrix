
%% movieOfRotateFlankerPosAngle 
%this purpose of this function is to confirm that the angles work as they
%should, that phases a line appropriately, and x and y offsets are correct

parameters=getDefaultParameters(ifFeatureGoRightWithTwoFlank,'goToRightDetection', '1_7', 'Oct.09,2007');

parameters.stdGaussMask = 1/16;
parameters.positionalHint=0;
c=1;
parameters.flankerContrast=c;
parameters.goRightContrast=c;
parameters.goLeftContrast=c;
parameters.flankerOffset=3.0;

orients=[0:0.1:(2*pi)];
%orients=pi/4;
phase=[0 pi/2];
clear m

for i=1%:length(orients)
    orient=orients(i)
%     orient=[pi/12 -pi/12 pi/4 -pi/4]; %for testing
     orient=[-pi/12 -pi/12];
     %orient=[pi/8 -pi/8];%  pi/8 -pi/8];
    parameters.phase=phase
    parameters.flankerPosAngle=[orient]; 
    parameters.goRightOrientations=orient;
    parameters.goLeftOrientations=orient;
    parameters.flankerOrientations=orient;
    [step parameters]=setFlankerStimRewardAndTrialManager(parameters, 'test');
    stim=getStimManager(step);
    [im details]=sampleStimFrame(stim,'nAFC');

    %save relevant details
    dev(i)=details.deviation;
    devPix(i,1:2)=details.devPix;
    flankerPos(i,1:2)=[details.stimRects(2,1) details.stimRects(2,3)] %y and x of upper left corner of first flanker
    %plot
    %plot
    figure(1)
    imagesc(im)
    axis equal
    colormap(gray)
    m(i)=getframe;
end

movie(m)
movie(m(1))

amplitudes=max(flankerPos)-min(flankerPos);

if diff([amplitudes])~=0

%     figure
%     plot(devPix,'--')
%     hold on;
%     plot(flankerPos)
%     devPix
% 
% 
%     figure 
%     title('do they both look like circles?');
%     plot(devPix(:,1), devPix(:,2))
%     hold on;
%     plot(flankerPos(:,1), flankerPos(:,2))
%     axis square

    amplitudes=amplitudes
    error('the amplitudes should be the same for x and y deviation')
end
%%



