subjects={'pmm'}; %pmm, test
path='C:\pmeier\Ratrix\Boxes\box1\';

data=loadRatrixData(path,subjects);

savefile='pmmData_Flanker_061203'
save(savefile, 'data')

%Session description
    %1_ start at chance, wrong contrast
    %2- junk
    %3- 6 contrats
    %4- 2 more contrasts easier
    %5- 8 contrast, just more trials
    %6- no flanker
    %7- flanker further away
    %8- more of flanker further away

%isIncludedInAnalysis=[3 4 5] %H-V flanker
isIncludedInAnalysis=[3 4 5 6] %H-V-N flanker
%isIncludedInAnalysis=[6 7 8] %H-V flanker, further away

count=0;
for i=1:size(data,1)
    if ~isempty(data{i,1})
        if ~isempty(data{i,2})
            count=count+1;
            realdata{count,1}=data{i,1};
            realdata{count,2}=data{i,2};
        else
            error('first element of data is not empty but second is')
        end
    else
        if ~isempty(data{i,2})
            error('first element of data is empty but second isn''t')
        end
    end
end
data=realdata

uniqueNames=unique({data{:,2}})

for subNum=1:length(uniqueNames)
    subData={data{strcmp({data{:,2}},uniqueNames{subNum}),1}};
    
    
    
    isIncludedInAnalysis=(length(subData)+1)-isIncludedInAnalysis;  %count backwards
   %isIncludedInAnalysis=[1:length(subData)];  % all


     %firstTrialTime=[];
     combinedData=[];
     for sessionNum=1:length(subData)
         sessionData=subData{sessionNum}.trialRecords;
         if length(sessionData)>=1  && ismember(sessionNum,isIncludedInAnalysis)
            % sessionData=sessionData(strcmp({sessionData.trialManagerClass},'nAFC'));
%              for i=1:length(sessionData)
%                  if isempty(firstTrialTime) || etime(firstTrialTime,sessionData(i).date)>0
%                      firstTrialTime=sessionData(i).date;
%                  end
%              end
            combinedData=[combinedData sessionData];
         end
     end
    
    combinedData
    
    %stimDetails=[sessionData.stimDetails];

    correct=[combinedData.correct];
    stimDetails=[combinedData.stimDetails];
    leftFlankerOrient=[stimDetails.leftFlankerOrient];
    contrast=[stimDetails.targetContrast];  % oops all low,  for unique
    uniqueContrasts=unique(contrast);
    flankerIsVertical=(leftFlankerOrient==0);
    flankerContrast=[stimDetails.flankerContrast];
    

        verticalTotal=[];
        verticalCorrect=[];
        pctCorrectVertical=[];
        horizontalTotal=[];
        horizontalCorrect=[];
        pctCorrectHorizontal=[];
        noFlankCorrect=[];
        noFlankTotal=[];
        pctCorrectNoFlank=[];
        for contrastType=1:length(uniqueContrasts)
            %depends on having only two orientations: vert and horiz
            these=(contrast==uniqueContrasts(contrastType)) & flankerIsVertical & (flankerContrast==1);
            verticalCorrect(contrastType)=sum(correct(these));
            verticalTotal(contrastType)=sum(these);
            pctCorrectVertical(contrastType)=verticalCorrect(contrastType)/verticalTotal(contrastType);

            these=(contrast==uniqueContrasts(contrastType)) & (~flankerIsVertical) & (flankerContrast==1);
            horizontalCorrect(contrastType)=sum(correct(these));
            horizontalTotal(contrastType)=sum(these);
            pctCorrectHorizontal(contrastType)=horizontalCorrect(contrastType)/horizontalTotal(contrastType);
            %pctCorrectHorizontal(contrastType)=sum(correct(~flankerIsVertical))/sum(~flankerIsVertical);
            
            these=(contrast==uniqueContrasts(contrastType)) &  (flankerContrast==0);
            noFlankCorrect(contrastType)=sum(correct(these));
            noFlankTotal(contrastType)=sum(these);
            pctCorrectNoFlank(contrastType)=noFlankCorrect(contrastType)/noFlankTotal(contrastType);
        end
        
        
        plot(uniqueContrasts,pctCorrectVertical,'bx',uniqueContrasts,pctCorrectHorizontal,'ro')
        plot([1:length(uniqueContrasts)],pctCorrectVertical,'bx',[1:length(uniqueContrasts)],pctCorrectHorizontal,'ro')
        hold on
        plot(1:length(uniqueContrasts),pctCorrectNoFlank,'k.')
        
        
        seeCI=0;
        if seeCI
            alpha=0.05;
            
            figure; hold on
            right=noFlankCorrect; attempt=noFlankTotal; [performance, pci] = binofit(right,attempt,alpha);
            errorbar([1:length(uniqueContrasts)],performance,performance'-pci(:,1),pci(:,2)-performance','k')

            right=verticalCorrect; attempt=verticalTotal; [performance, pci] = binofit(right,attempt,alpha);
            errorbar([1:length(uniqueContrasts)],performance,performance'-pci(:,1),pci(:,2)-performance','b')

            right=horizontalCorrect; attempt=horizontalTotal; [performance, pci] = binofit(right,attempt,alpha);
            errorbar([1:length(uniqueContrasts)],performance,performance'-pci(:,1),pci(:,2)-performance','r')

        end
        
        makeImages=0;
        if makeImages
            subjectID='pmm';
            s=getSubjectFromID(r,subjectID);
            [p t]=getProtocolAndStep(s);
            step=getTrainingStep(p,t);
            stimulus=getStimManager(step)
            
            subjectID='pmm';
            [p t]=getProtocolAndStep(getSubjectFromID(r,subjectID));
            stimulus=getStimManager(getTrainingStep(p,t))
            
            trialManagerClass='nAFC';
            frameRate=100;
            responsePorts=[1 3];
            totalPorts=[3];
            width=800;
            height=600;
            trialRecords=[];
            
            displaySize=[];
            LUTbits=[];
            resolutions=Screen('Resolutions');
            [stimulus updateSM resInd out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance text] = ...
                calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords);
            imagesc(out(:,:,2))
            imwrite(uint8(out(:,:,2)*255),'stimExample.jpg')  
        end
    
end
