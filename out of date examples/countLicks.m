ratID='rat_127';


d=load(fullfile('C:\pmeier\Ratrix\Boxes\box1\subjectData',ratID,'trialRecords.mat'))

if all(strcmp({d.trialRecords.trialManagerClass},'freeDrinks'))
    t=[d.trialRecords.trialManager];
    if any([t.pctStochasticReward]>0)
        error('stochastic was not zero')
    else

        dates=reshape([d.trialRecords.date]',6,length(d.trialRecords))';
        if length(unique(dates(:,3)))==1
            sum(reshape([d.trialRecords.response],3,length(d.trialRecords))')
        else
            error('not all on same date')
        end
    end
else
    error('not all free drinks')
end