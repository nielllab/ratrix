function [delta CI numSamplesUsed]=compareAtoBbinofit(more,Aind,Bind,statType,alpha)
% computes stat_a - stat_b

if ~exist('alpha','var') || isempty(alpha)
    alpha=0.05;
end

switch statType
    case 'pctCorrect'
        x1= sum(more.numCorrect(Aind,:),1);
        n1= sum(more.numAttempted(Aind,:),1);
        x2= sum(more.numCorrect(Bind,:),1);
        n2= sum(more.numAttempted(Bind,:),1);

    case 'hits'
        x1= sum(more.hits(Aind,:),1);
        n1= sum(more.hits(Aind,:) + more.misses(Aind,:),1);
        x2= sum(more.hits(Bind,:),1);
        n2= sum(more.hits(Bind,:) + more.misses(Bind,:),1);

    case 'yes'
        x1= sum(more.FAs(Aind,:) + more.hits(Aind,:),1);
        n1= sum(more.FAs(Aind,:) + more.hits(Aind,:) + more.misses(Aind,:) + more.CRs(Aind,:),1);
        x2= sum(more.FAs(Bind,:) + more.hits(Bind,:),1);
        n2= sum(more.FAs(Bind,:) + more.hits(Bind,:) + more.misses(Bind,:) + more.CRs(Bind,:),1);

    case 'CRs'
        x1= sum(more.CRs(Aind,:),1);
        n1= sum(more.CRs(Aind,:) + more.FAs(Aind,:),1); % was wrong until 081105, now fixed
        x2= sum(more.CRs(Bind,:),1);
        n2= sum(more.CRs(Bind,:) + more.FAs(Bind,:),1); % was wrong until 081105, now fixed
        
    case 'dprime' %consider dprimeMCMC
        a.hits= sum(more.hits(Aind,:),1);
        a.misses= sum(more.misses(Aind,:),1);
        a.FAs= sum(more.FAs(Aind,:),1);
        a.CRs= sum(more.CRs(Aind,:),1);
        
        b.hits= sum(more.hits(Bind,:),1);
        b.misses= sum(more.misses(Bind,:),1);
        b.FAs= sum(more.FAs(Bind,:),1);
        b.CRs= sum(more.CRs(Bind,:),1);
  
    otherwise
        statType
        error('Bad statType');
end

switch statType
    case {'pctCorrect', 'yes', 'hits', 'CRs'}
        
        binomialMethod='agrestiCaffo';%wald';
        [delta CI]=diffOfBino(x2,x1,n2,n1,binomialMethod,alpha); %a=x1 & b=x2 so the desired a-b is correctly x1 -x2 because uses p2-p1 in this function
        
    otherwise
        statType
        error('bad type');
end
        
numSamplesUsed=n1+n2;
