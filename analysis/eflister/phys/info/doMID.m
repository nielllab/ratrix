%note this searches on all dims at once to take advantage of synergy
%but it easily gets stuck on a broad plateu where it can just spin the dims in their subspace
%so need to come up with anti-spinning strategy
%could search for each dim incrementally, pinning each one as you find it, but that won't take advantage of synergy.
%also: should i be forcing them to be orthogonal?  maybe not...
%and: maybe each one should have its own gain factor so it can stretch...
function [bestDims,bestEdges]=doMID(totalMI,repeatStim,repeatResponses,filts,nBins,numRepeats)

%search
iterations=200;
stepSize=.05;
delta=1; %use this percent of step size to estimate gradients (seems to be bad to have this small)
annealSchedule=linspace(.6,0,iterations);
annealSchedule=annealSchedule.^5;
consecutiveFlatsToRestart=5;
flatThresh=0.1; %the percent of the max encountered gradient magnitude to call flat

doMovie=1;
movieName='example16.avi';

%%%%%%%%%%%%%%%%%%
numDims=size(filts,1);
dimLength=size(filts,2);

% tic
% bigResponseIndex=getIndexedResponses(repeatResponses,[1:10]);
% toc
% responseIndex=bigResponseIndex{1}{1};
responseIndex=getIndexedResponses(repeatResponses,1);
responseIndex=responseIndex{1};

fig=figure;
set(fig,'DoubleBuffer','on');
if doMovie
    mov = avifile(movieName,'compression','Cinepak');
end

%[totalMI h hSpk]=mutualInfo(repeatStim,repeatResponses,responseIndex);  %NOT total MI!  this only considers the instantaneous value of the stim at the time of the spike.
%that's why we weren't violoating data processing inequality by blowing this value out of the water by picking good filters.

%hillclimb
colors=jet;
testDims=randn(numDims,dimLength);
bestMI=0;
consecutiveFlats=0;
gradNorms=zeros(1,iterations);
lastStart=1;
minEff=0.5;
for i=1:iterations-1
    disp(['iteration: ' num2str(i)])

    [testDims projectedStim]=orthAndFilt(testDims,repeatStim);

    [testMI h hSpk edges stimCounts trigCounts]=mutualInfo(projectedStim,repeatResponses,responseIndex,nBins,numRepeats);

    if testMI>bestMI
        bestEdges=edges;
        [edges(1:3) edges(end-3:end)]
        bestMI=testMI;
        bestDims=testDims;
        disp([sprintf('\tnew best mi found: ') num2str(bestMI)])
        bold=3;
    else
        bold=1;
    end

    for d=1:numDims
        subplot(2*numDims+6,1,2*d-1)
        plot(testDims(d,:),'color',colors(ceil((i/iterations)*size(colors,1)),:),'LineWidth',bold)
        hold on
        plot(filts(d,:),'k','LineWidth',3)
    end

    subplot(2*numDims+6,1,2*numDims+1)
    plot(i,testMI/totalMI,'kx')  %very odd: we seem to be doing better than best
    %minEff=min([testMI/totalMI minEff]);
    %ylim([minEff 1])
    xlim([0 iterations])
    hold on

     [maxPSpkPosterior, meanPSpkPosterior]=doHierarchicalBayes(trigCounts,stimCounts);
    
    warning off 'MATLAB:divideByZero'
    if numDims>1
        if numDims~=size(size(h),2);
            error('bad dims')
        end

        if numDims>2
            dimDivs=size(h,1);
            h=reshape(h,dimDivs,[]);
            hSpk=reshape(hSpk,dimDivs,[]);
            maxPSpkPosterior=reshape(maxPSpkPosterior,dimDivs,[]);
            meanPSpkPosterior=reshape(meanPSpkPosterior,dimDivs,[]);
        end
        subplot(2*numDims+6,1,2*numDims+2)
        imagesc(h)
        subplot(2*numDims+6,1,2*numDims+3)
        imagesc(hSpk)
        subplot(2*numDims+6,1,2*numDims+4)
        imagesc(hSpk./h)
        
        subplot(2*numDims+6,1,2*numDims+5)
        imagesc(maxPSpkPosterior)
        subplot(2*numDims+6,1,2*numDims+6)
        imagesc(meanPSpkPosterior)
        
    elseif numDims==1
        if size(h,2)~=numDims
            error('bad dims 2')
        end
        subplot(2*numDims+6,1,2*numDims+2)
        cla
        plot(h,'k')
        hold on
        %subplot(2*numDims+4,1,2*numDims+3)
        plot(hSpk,'r')
        subplot(2*numDims+6,1,2*numDims+3)
        plot(hSpk./h)
        subplot(2*numDims+6,1,2*numDims+4)
        

    
   
    

        
        plot(maxPSpkPosterior,'k')
        hold on
        plot(meanPSpkPosterior,'b')
        legend({'mode','mean'})
        hold off
        
    else
        error('problem')
    end
    warning on 'MATLAB:divideByZero'

    grads=zeros(numDims,dimLength);
    for k=1:numDims
        disp([sprintf('\t\tdim: ') num2str(k)])
        for j=1:dimLength
            %disp([sprintf('\t\tcoordinate: ') num2str(j) ' of dim: ' num2str(k)])

            gradDims=testDims;
            gradDims(k,j)=gradDims(k,j)+delta*stepSize;
            [gradDims projectedStim]=orthAndFilt(gradDims,repeatStim);
            [grads(k,j) h hSpk edges garbage garbage]=mutualInfo(projectedStim,repeatResponses,responseIndex,nBins,numRepeats);
            grads(k,j)=grads(k,j)-testMI;

            %         if j==13
            %             subplot(3,1,3)
            %             plot(testDim,'k')
            %             hold on
            %             plot(gradDim,'r')
            %         end

        end
    end

    for d=1:numDims
        subplot(2*numDims+6,1,2*d)
        plot(grads(d,:),'color',colors(ceil((1-(i/iterations))*size(colors,1)),:))
        hold on
    end
    drawnow

    gradNorms(i)=norm(grads(:));

    disp(sprintf('\tnorm of grads is %g',gradNorms(i)))

    testDims=testDims+grads*(stepSize/gradNorms(i))+annealSchedule(i-lastStart+1)*randn(numDims,dimLength);

    if gradNorms(i)<flatThresh*max(gradNorms(lastStart:i))
        consecutiveFlats=consecutiveFlats+1;
        disp(sprintf('\tgot flat!'))
        if consecutiveFlats>consecutiveFlatsToRestart
            disp(sprintf('\trestart!'))
            consecutiveFlats=0;
            lastStart=i;
            testDims=randn(numDims,dimLength);
        end
    else
        disp([sprintf('\tgrad norm: ') num2str(gradNorms(i)/max(gradNorms(lastStart:i)))])
    end

    if doMovie
        if i==1
            disp('move figure to desired place/size')
            pause
        end
        F = getframe(gcf);
        mov = addframe(mov,F);
    end
end
if doMovie
    mov = close(mov);
end

if 0
    %%%%%%%%%%%%%%% take quick chance to do a spike triggered analysis
    expansionLength=ceil(1.5*size(filts,2));
    repeatStimExpanded=repeatStim(repmat([1:length(repeatStim)-expansionLength+1]',1,expansionLength)+repmat(0:expansionLength-1,length(repeatStim)-expansionLength+1,1));
    trigTimes=responseIndex{1};
    trigTimes=trigTimes(trigTimes>=expansionLength)-expansionLength+1;
    trigs = repeatStimExpanded(trigTimes,:);

    figure
    [h c]=hist(trigs,500);
    subplot(4,1,1)
    imagesc(h)
    subplot(4,1,2)
    plot(mean(trigs),'r')
    hold on
    plot([zeros(size(filts,1),expansionLength-size(filts,2)) filts]','k')
    plot([zeros(size(filts,1),expansionLength-size(filts,2)) bestDims]','b')
    subplot(4,1,3)
    c=cov(trigs);
    cNoDiag=c;
    cNoDiag(logical(eye(size(c,1))))=0;
    cNoDiag(logical(eye(size(c,1))))=sum(cNoDiag(:))/(size(c,1)^2-size(c,1));
    imagesc(cNoDiag)
    subplot(4,1,4)
    plot(diag(c))
    %%%%%%%%%%%%%%%%
end