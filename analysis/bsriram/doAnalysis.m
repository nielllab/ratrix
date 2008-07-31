for j = {'267','268','269','270'}
fhan = figure('Name',char(j),'Numbertitle','off');
smallData = getSmalls(char(j),[],2,1);
doPlot('percentCorrect',smallData,fhan,2,2,1,[],1);
title('percentCorrect'); xlabel('trials with 100 trial window');
doPlot('plotTrialsPerDay',smallData,fhan,2,2,2,[],1);
title('plotTrialsPerDay'); xlabel('days since start');
doPlot('plotBias',smallData,fhan,2,2,3,[],1);
title('plotBias'); xlabel('trials with 100 trial window');
doPlot('plotRatePerDay',smallData,fhan,2,2,4,[],1);
title('plotRatePerDay'); 
end