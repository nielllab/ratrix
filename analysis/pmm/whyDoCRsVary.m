function x=y(a)
%why does CR have variable performance across TARGET conditions (which is alwways contrast 0)

%% are there unique and correct parameters as the result of getFlankerConditionInds?

subjects={'228'}%, '227','138','139','230','233','234','237'}; %left and right, removed 229 274 231 232 too little data for 9.4., 
d=getSmalls('228')
[conditionInds names haveData colors]=getFlankerConditionInds(d,getGoods(d),'16flanks');

numConditions=size(conditionInds,1);
parameters=zeros(numConditions,4);
for i=1:numConditions
parameters(i,:)=[unique(d.targetContrast(conditionInds(i,:))) unique(d.targetOrientation(conditionInds(i,:)))...
    unique(d.flankerOrientation(conditionInds(i,:))) unique(d.flankerPosAngle(conditionInds(i,:)))];
end
parameters

%answer: YES

%% Are there no hits for the first half of the conditions? No CRs for the second half?

[stats CI names params]=getFlankerStats(subjects,'16flanks',{'hits','CRs','yes'},'9.4',dateRange)
bad=isnan(stats)
ht=params.raw.numHits;
cr=params.raw.numCRs;
ht>0
cr>0
params.raw
%answer: yes

%% are there roughly an equal number of each condition?
figure; bar(params.raw.numAttempt); axis([0 numConditions 0 2*max(params.raw.numAttempt)])
%answer: yes

%% if you look at the 8flank matched, do the hit counts match that from the 16flank?

[stats CI names params]=getFlankerStats(subjects,'8flanks',{'hits','CRs','yes'},'9.4',dateRange)
ht2=params.raw.numHits
cr2=params.raw.numCRs;
hitsSame=ht(9:end)==ht2
crsSame=cr(1:8)==cr2

%answer: yes

%% if you compare the matched noSig conditions with different targets, is there, as we expect, no speration between target changing conditions?

 cMatrix={[1],[3];
     [2],[4];
     [5],[7];
     [6],[8];}; %vary target, noSig 
 
 %checked all
 parameters([6 8],:) % only the second colum varies
 
 % look at a bunch of animals
 subjects={'228','227','138','139','230','233','234','237'}; %left and right, removed 229 274 231 232 too little data for 9.4., 
 [stats CI names params]=getFlankerStats(subjects,'16flanks',{'hits','CRs','yes'},'9.4',dateRange)
 viewFlankerComparison(names,params, cMatrix)
 
%answer: yes (okay thats good)
%clarify: hits cant vary b/c there are none but we have giant error bars (good)
%CRs could in principle vary, but don't confirming sanity (no hidden timming efects, no bad code, etc)
%% now compare across targets when the contrast is larger. do they vary some like we expect?

 cMatrix={[9],[11];
     [10],[12];
     [13],[15];
     [14],[16];}; %across targets w/ sig 
 
  viewFlankerComparison(names,params, cMatrix,[],[],[-30:30])
  
%CRs CANT vary since target is always here, there should be NO CR conditions (yet there are!)
% confirmed there are no CRs in the last 8 conditions
% params.raw.numCRs


% yes there are none
% code error! was in compareAtoBbinofit. Fixed now.

%NOTE: similarity between hits and yes
%this should be, b/c since the target is alway there in these conditions, every yes is a hit

%ALSO: notice how the yes=left rats have an opposite favoritism for the
%target orientation? thats real.  and BIG

