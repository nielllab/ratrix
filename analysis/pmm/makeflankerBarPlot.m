function makeflankerBarPlot(r,subjects)

%where I left off:  I confrimed that the conditions are correctly paired
%with the images of them
% i have not confirmed the parameters of targetcontrast match the reasoning of the hits vs. miss 
%i.e:         hits(i,j)=sum(d.correct(conditionInd(j,:))==1); %sig, correc
%(though the code makres sense based on the indices of the images)
% i should NOT pool left and right rats without looking at them in detail
% i should NOT pool tip-left vs. tip-right stims without looking in detail
% i should confirm that other code gets similar results. finish
% getFlankerConditionInds('colin+3symety)
% there appears to be an inversion of performance across the left VS. right rats
% (in the popout conditions, when split out for left-tipped and right-tipped)
% the biggest variability in no-stimulus conditions is the ANGLE of the
% flanker and NOT the configuration! this suggests that one is
% intrinsically more visible (230 has it particulary strong, 
% two other rats have it weakly, oner rats don't have it)

% test: look at data prior to flankers. Is ther an targetOrientation bias?
%-->some rats have a weak effect: (ie. 234, but 237 has the opposite angle prefference) 
%--> on average, across rats, there is no effect in targetOrientation

% so the wierdness in aquired with the flankers?
% --> not really, on a rat by rat basis, the seem to have evidence of their
% biases before the flankers are there.  Its just that they are weaker and
% balanced out.  In fact the rew rats who end up "unbiased" with flankers (237) started out with
% a bias for the opposite dirrection as most rats end up with


if ~exist('r')
   load('C:\Documents and Settings\rlab\Desktop\db081013')
end

orient= pi/8;  %temp

if ~exist('subjects')
    side='right'
    switch side
        case 'right'
    subjects={'138','139','229','230','233','234','237'} % right
        subjects={'229','230','233','234','237'} % 138, 139 removed if pre-flanker test b/c wierd past
    %'278' not good enough
     orient= pi/12;  
        case 'left'
    subjects={'227','228','231','232'}%,'274'} % left, bigger tilt too
        %274 has a temp corrupt complied file
    orient= pi/8;  
    end
end

%%


sweptParameters={'flankerOrientation','targetOrientation','flankerPosAngle','targetContrast'}; % last entry must be targetContrast
sweptValues={orient*[-1 1],orient*[-1 1],orient*[-1 1],[0 1]};
    


for i=1:length(subjects)
    d=getSmalls(subjects{i});
    d=removeSomeSmalls(d,~getGoods(d,'withoutAfterError') | d.flankerContrast~=0.4); %main
    %d=removeSomeSmalls(d,~getGoods(d,'withoutAfterError') | d.flankerContrast~=0);  %pre-flanker test
    d=addYesResponse(d,r);
    unique(d.targetOrientation)
    %figure; doPlotPercentCorrect(d)
    %sweptValues='extractUniqueValuesFromData'; %some rats have different
    %orientations, but gets too many contrasts
    [images numTrials returnSweptValues conditionInd]=getStimSweep(r,d,sweptParameters,sweptValues,true);
    
    
    n=size(conditionInd,1);
        
    %check to make sure values are good for analysis
    tc=returnSweptValues{find(strcmp(sweptParameters,'targetContrast'))}
    if ~(length(tc)==2 && ismember(0,tc) &&ismember(1,tc))
        targetContrastValues=tc
        error('must have sig condition and a no sig condition' )
    else
        %check the contrast of the last half is 0
        for j=(n/2)+1:n
            theseInds=find(conditionInd(i,:));
            if ~isempty(theseInds)
                tc=d.targetContrast(theseInds(1));
                if tc~=0
                    j=j
                    n=n
                    tc=tc
                    error('targetContrast should be 0 in that position')
                end
            end
        end
    end

    for j=1:n/2
        hits(i,j)=sum(d.correct(conditionInd(j,:))==1); %sig, correc
        CRs(i,j)=sum(d.correct(conditionInd(n/2+j,:))==1); %no sig, correct
        misses(i,j)=sum(d.correct(conditionInd(j,:))==0); % sig, incorrect
        FAs(i,j)=sum(d.correct(conditionInd(n/2+j,:))==0); %no sig, incorrect
    end
    
    for j=1:n
        numAttempts(i,j)=sum(conditionInd(j,:));
        numCorrect(i,j)=sum(d.correct(conditionInd(j,:)));
        numYes(i,j)=sum(d.yes(conditionInd(j,:)));
    end
end

%% get the images
sweptParameters{end+1}='flankerContrast';
sweptValues{end+1}=[0.4];
[images numTrials sweptValues conditionInd]=getStimSweep(r,d,sweptParameters,sweptValues,false);

%%
if 0  %test if stims are correct
    for i=1:length(images(:))
        figure; image(uint8(images{i})); colormap(gray(255))
        theseInds=find(conditionInd(i,:))
        if ~isempty(theseInds)
        to=d.targetOrientation(theseInds(1))
        fo=d.flankerOrientation(theseInds(1))
        fpa=d.flankerPosAngle(theseInds(1))
        else
            disp('never happened!')
        end
        pause
    end
end

%% plot single rat

for i=1:n/2
    imagePairs{i}={images{i},images{i+n/2}}
end
    
X=ceil((length(subjects)+1)/2);
Y=2;

%these plots are based on the assumption of an equal number of sig and no
%sig trials! else we calulate the h

figure;
for i=1:length(subjects) 
    subplot(X,Y,i); doBarPlotWithStims(hits(i,:)+CRs(i,:)+misses(i,:)+FAs(i,:),hits(i,:)+CRs(i,:),imagePairs); %correct = hits+CRs
    title(subjects{i})
end
subplot(X,Y,i+1); doBarPlotWithStims(sum(hits+CRs+misses+FAs),sum(hits+CRs),imagePairs)
title('all'); ylabel('pctCorrect')

figure;
for i=1:length(subjects) 
    subplot(X,Y,i); doBarPlotWithStims(hits(i,:)+CRs(i,:)+misses(i,:)+FAs(i,:),hits(i,:)+FAs(i,:),imagePairs); %yes = hits+FAs
    title(subjects{i})
end
subplot(X,Y,i+1); doBarPlotWithStims(sum(hits+CRs+misses+FAs),sum(hits+FAs),imagePairs)
title('all'); ylabel('pctYes')

figure;
for i=1:length(subjects) 
    subplot(X,Y,i); doBarPlotWithStims(numAttempts(i,:),numCorrect(i,:),images); 
    title(subjects{i})
end
subplot(X,Y,i+1); doBarPlotWithStims(sum(numAttempts),sum(numCorrect),images)
title('all'); ylabel('pctCorrect')

figure;
for i=1:length(subjects) 
    subplot(X,Y,i); doBarPlotWithStims(numAttempts(i,:),numYes(i,:),images); 
    title(subjects{i})
end
subplot(X,Y,i+1); doBarPlotWithStims(sum(numAttempts),sum(numYes),images)
title('all'); ylabel('pctYes')

figure
doBarPlotWithStims(sum(numAttempts),sum(numYes),images)
title('all'); ylabel('pctYes')

figure
doBarPlotWithStims(sum(numAttempts),sum(numCorrect),images)
title('all'); ylabel('pctCorrect')

