function [deltas CIs comparisonNames moreComparisonFacts]=flankerComparisonCI(d, statTypes,cMatrix,conditionType)
%returns confidence intervals of the magnitude of the difference between the conditions
% d-smallData 
% statType-pctCorrect, hit, yes, CR
% cMatrix-cell array 2xN numberComparison such that cMatrix{n,1}=aIndices and cMatrix{n,2}=bIndices 
% conditionType-'colin+3', etc.
% cMatrix={[1],[3];
%     [1],[2,3,4];
%     [2],[1,3,4];
%     [3],[1,2,4];
%     [4],[1,2,3]};
%[deltas CIs comparisonNames]=flankerComparisonCI(d,'pctCorrect',cMatrix)


%initialize
deltas=[]; CIs=[]; comparisonNames={}; moreComparisonFacts=[];

totalTrials=length(d.date);
goods=getGoods(d,'withoutAfterError');

%Simple example
%[conditionInds names haveData colors]=getFlankerConditionInds(d,goods,'colin+3');
%[pct more]=performancePerConditionPerDay(totalTrials,conditionInds,goods,d);
%[delta CI]=compareAtoB(more,[1],[2:4])

[conditionInds names haveData colors]=getFlankerConditionInds(d,goods,'colin+3');
[pct more]=performancePerConditionPerDay(totalTrials,conditionInds,goods,d);
% 1st cMatrix is defined by input
[deltas CIs comparisonNames moreComparisonFacts] = addComparisions(more,cMatrix,statTypes,conditionInds,names,deltas, CIs, comparisonNames, moreComparisonFacts);
moreComparisonFacts.details=more;

function [deltas CIs comparisonNames, moreComparisonFacts] = addComparisions(more,cMatrix,statTypes,conditionInds,names,deltas, CIs, comparisonNames, moreComparisonFacts)

offset=size(deltas,1);
for i=1:size(cMatrix,1)
    index=offset+i;
    for j=1:size(statTypes,2)
        [deltas(index,j) CIs(index,j,1:2) numSamples] = compareAtoBbinofit(more,cMatrix{i,1},cMatrix{i,2},statTypes{j});
        moreComparisonFacts.numSamples(index,j)=numSamples;
    end

    %determine name
    if all(size(cMatrix{i,1})==[1 1]) && size(setdiff([1:size(conditionInds,1)],union(cMatrix{i,1},cMatrix{i,2})),2)==0
        Aname=names{cMatrix{i,1}};
        Bname='other';
    elseif all(size(cMatrix{i,1})==[1 1]) && all(size(cMatrix{i,2})==[1 1])
        Aname=names{cMatrix{i,1}};
        Bname=names{cMatrix{i,2}};
    else
        cMatrix{i,1}
        cMatrix{i,2}
        error('bad selection of comparisons, only two single conditions or one vs. the rest')
    end
    comparisonNames{index,1}=sprintf('(%s) minus (%s)',Aname,Bname);

end




