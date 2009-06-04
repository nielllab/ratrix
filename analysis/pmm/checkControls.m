

subjects={'228','227','230','233','229'}; %there might be others!  
% on colin only: 234  231
%  doesn't have these trials: '139','275','277'  (confirm step)
% 232, 237 have side violation?  (need to figure out whats up!)
%chance performance: '138' (for how long now?)
%subjects={'237','229','227','230'}; % previous constant test
dateRange=[pmmEvent('endToggle') now];
filter{1}.type='11';
[stats CI names params]=getFlankerStats(subjects,'8flanks+',{'pctCorrect','CRs','hits','yes'},filter,dateRange)



% filter{2}.type='performancePercentile';
% filter{2}.parameters.goodType='withoutAfterError';
% filter{2}.parameters.whichCondition={'noFlank',1}
% filter{2}.parameters.performanceMethod='pCorrect';
% filter{2}.parameters.performanceParameters={[.25 1],'boxcar',100}

              
%[stats2 CI2 names2
%params2]=getFlankerStats(subjects,'8flanks+',{'pctCorrect','CRs','hits','yes'},filter,dateRange)
arrows={'para','colin'};
%figure; doHitFAScatter(stats2,CI2,names2,params2,[],{'changeFlank','colin'},0,0,0,0,0,3,arrows);
figure; doHitFAScatter(stats,CI,names,params,subjects,{'para','colin'},0,0,0,0,0,3,arrows);

cMatrix=[];
statTypes=[];
viewFlankerComparison(names,params,cMatrix,statTypes,subjects,[],[],1,1,false,false, [], 1);