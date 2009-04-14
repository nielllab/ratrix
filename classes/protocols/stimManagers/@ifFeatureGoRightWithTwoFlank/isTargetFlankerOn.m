function   [targetIsOn flankerIsOn effectiveFrame cycleNum sweptID repetition]=isTargetFlankerOn(s,frame)
%if a single frame, returns a pseudo logical value for each output (0 or 1) 
%if multiple frames, returns a vector of zeros or sweptID
%for logicals, use targetIsOn >0

if ~isempty(s.dynamicSweep) 
    %determine the effective frame
    framesPerCycle=double(max([s.targetOnOff s.flankerOnOff]));
    cycleNum=floor(frame/framesPerCycle)+1;
    effectiveFrame=mod(frame, framesPerCycle); 
    
    %prevent frame values of 0 
    zeroInds=find(effectiveFrame==0);
    cycleNum(zeroInds)=cycleNum(zeroInds)-1;
    effectiveFrame(zeroInds)=framesPerCycle;
    
    %get the id of the swept params
    cyclesPerID=size(s.dynamicSweep.sweptValues,2);
    repetition=floor(cycleNum/cyclesPerID)+1;
    sweptID=mod(cycleNum, cyclesPerID); 
    
     %prevent ID values of 0 
    zeroInds=find(sweptID==0);
    repetition(zeroInds)=repetition(zeroInds)-1;
    sweptID(zeroInds)=cyclesPerID;
else
    effectiveFrame=frame;
    cycleNum=ones(size(frame));
    sweptID=ones(size(frame));
    repetition=ones(size(frame));
end

targetIsOn=(effectiveFrame>=s.targetOnOff(1) & effectiveFrame<s.targetOnOff(2));
flankerIsOn=(effectiveFrame>=s.flankerOnOff(1) & effectiveFrame<s.flankerOnOff(2));

if length(frame)>1
    targetIsOn=double(targetIsOn).*sweptID;
    flankerIsOn=double(flankerIsOn).*sweptID;
end

