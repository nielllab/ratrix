function [hiBehState_meanDthCRFacrossSess] = plotCompareBehState_CRF2(loBehState_allSessAllPtsAllDurs_CRF,hiBehState_allSessAllPtsAllDurs_CRF,durat,yMax,yMin,yLimit,x_axis,xMax,xMin,xLimit,stateLegend,uniqueContrasts,reigons,nGroup)

figure
%clear titleText
%titleText = 'CRF: locomotion';
%suptitle(sprintf('%s \n',titleText))

%titleText = 'CRF: '; % making char variables for sprintf/title later
%subjName = groupSubjName{1}; % will be same name if w/in mouse analysis...
%date = groupDate{1};
%suptitle(sprintf('%s',titleText,subjName)); % date, 

for d = durat
    
    for i = 1:size(loBehState_allSessAllPtsAllDurs_CRF,3)
        
        % take mean across sessions, for ith point, lo beh state
        loBehState_meanDthCRFacrossSess = mean(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:),4);
        % get stdev across sessions
        loBehState_stdErrOverSess = std(squeeze(loBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))')/sqrt(size(loBehState_allSessAllPtsAllDurs_CRF,4)); 
        
        % take mean across sessions, for ith point, hi beh state
        hiBehState_meanDthCRFacrossSess = mean(hiBehState_allSessAllPtsAllDurs_CRF(d,:,i,:),4);
        % get stdev across sessions
        hiBehState_stdErrOverSess = std(squeeze(hiBehState_allSessAllPtsAllDurs_CRF(d,:,i,:))')/sqrt(size(hiBehState_allSessAllPtsAllDurs_CRF,4)); 

    end % end i loop
    
end % end d loop

end