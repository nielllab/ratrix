function continualAnalysisSTA()
%plots a bunch of features and color codes;

path='\\132.239.158.179\datanet_storage';

events={20,'iso off'; 59, '1st jaw move';68, '1st sacade'};


ifi=1/100;  % get from data
%pSA=find(strcmp(eyeDataVarNames,'pSA***'));  

startTrial=401;
numTrials=120;
trials=[1:numTrials];
STAs=[];
for i=trials
	tr=startTrial+i-1
    [data success]=getPhysRecords(fullfile(path,'test4'),{'trialRange',[tr tr]},{'analysis','spike','eye'},'temporalWhiteNoise');  
%     if ~success
%         warning('bad')
%         keyboard
%     else
%         D{i}=data;
%     end
    
	%the eye data
    pupil_area=data.eyeData(:,strcmp(data.eyeDataVarNames,'pupil_area'));
    SA(i)=mean(pupil_area);
    
    [px py crx cry]=getPxyCRxy(data);
    eyeSig=[crx-px cry-py];
	eyeMotion(i)=std(eyeSig(1,:));
    eyeCenter(i)=mean(eyeSig(1,:));

	%calc the rate during the mean screen of the interTrial
	%firstFrameTime=data.frameTimes(1,1)
	%interTrialCount=sum(data.spikeTimestamps< firstFrameTime);
    %interTrialDur= firstFrameTime -data.neuralDataTimes(1);
	%meanScreenRate(i)= interTrialCount/interTrialDur;
    count=length(data.spikeTimestamps);
    dur=range(data.spikeTimestamps);
    rate(i)=count/dur;
	
	%timeWindowMs=[300 50];  get dirrect
    
	%the STA data
	STA=data.analysisdata.STA(:)';  %unwrap 3d to 1D
	peakInd=find(STA==max(STA));
	peakTime(i)= 1000 * (31-peakInd) * ifi;
	peak(i)=STA(peakInd);
	amplitude(i)=diff(minmax(STA));
	STAs(i,:)=STA;
end

peak=peak/max(peak);
amplitude= amplitude/max(amplitude);

figure;
n=5;
subplot(n,1,1); plot(trials, SA,'k'); ylabel('pupil size') %addSTAEvents(events,max(SA)); 
subplot(n,1,2); plot(trials, eyeMotion,'k');  ylabel('eye motion'); % addSTAEvents (events,max(eyeMotion));
subplot(n,1,3); plot(trials, rate,'k');   ylabel('rate(Hz)'); %addSTAEvents (events,max(meanScreenRate));
subplot(n,1,4); plot(trials, amplitude,'k');  ylabel('peakAmp )') % addSTAEvents (events,max(eyeMotion));
subplot(n,1,5); plot(trials, peakTime,'k');  ylabel('peakTime'); % addSTAEvents (events,max(eyeMotion));
set(gca,'ylim',[30 120])

%color coded groups of STA
figure; hold on
numEvents=size(events,1);
colors=jet(numEvents)
prevEvent=1;  % init
times=([1:size(STAs,2)]*ifi)  % can we calc this better?
for i=1:numEvents
	these=STAs(prevEvent:events{i,1},:);
	plot(times, these,'color',colors(i,:))
	plot(times,mean(these),'color',colors(i,:),'lineWidth',3)
	prevEvent=events{i,1};
end


