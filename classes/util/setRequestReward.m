function r=setRequestReward(r,subjectIDs,value,verbose)
error('edf 12.11.08: this is poorly coded -- should be a class method, should not hardcode author/comment, should not recreate protocol, should not test tm methods, etc.  please rewrite in style of setup/util/setReinforcementParam')
%setRequestReward(r,subjectIDs,value)
%setRequestReward(r,{'127'},30)

if ~exist('verbose','var')
    verbose=0;
end

for i=1:length(subjectIDs)
  
    if verbose
        disp(sprintf('attempting to set requestReward for %s',subjectIDs{i}));
    end
    
    didChange=0;
    %p=getProtocolForSubjectID(r,subjectIDs{i});
    sub=getSubjectFromID(r,subjectIDs{i});
    [p currentStepNum]=getProtocolAndStep(sub);
    
    numSteps=getNumTrainingSteps(p);
    for j=1:numSteps
        step=getTrainingStep(p,j);
        tm=getTrialManager(step);
        if ismethod(tm,'setRequestReward')
            didChange=1;
            tm=setRequestReward(tm,value);
            step=setTrialManager(step,tm);
            comment=sprintf('requestReward changed on step %d to %2.2g',j,value);
            
            if verbose
                disp(sprintf('SET VALUE: for step %d, setting request reward to %2.2g',j,value))
            end
        else
            if verbose
                disp(sprintf('no setting for step %d, %s',j,class(tm)))
            end
        end
        stepList{j}=step;
    end
    %pause % to view verbose
    if didChange
        newP=protocol(getName(p),stepList);
    	[sub r]=setProtocolAndStep(sub,newP,1,1,0,currentStepNum,r,comment,'pmm');
    end
end
