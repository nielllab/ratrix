function out=extractBasicFields(sm,trialRecords)

%note many of these are actually restricted by the trialManager -- ie
%nAFC has scalar targetPorts, but freeDrinks doesn't.

bloat=false;

out.trialNumber                 =ensureScalar({trialRecords.trialNumber});
out.sessionNumber               =ensureScalar({trialRecords.sessionNumber});
out.date                        =datenum(reshape([trialRecords.date],6,length(trialRecords))')';

temp=[trialRecords.station];
if bloat out.stationID          =ensureTypedVector({temp.id},'char'); end
out.soundOn                     =ensureScalar({temp.soundOn});
if bloat out.rewardMethod       =ensureTypedVector({temp.rewardMethod},'char'); end
if bloat out.MAC                =ensureTypedVector({temp.MACaddress},'char'); end
out.physicalLocation            =ensureEqualLengthVects({temp.physicalLocation});
out.numPorts                    =ensureScalar({temp.numPorts});

out.trainingStepNum             =ensureScalar({trialRecords.trainingStepNum});
if bloat out.protocolName       =ensureTypedVector({trialRecords.protocolName},'char'); end
out.numStepsInProtocol          =ensureScalar({trialRecords.numStepsInProtocol});

temp=[trialRecords.protocolVersion];
out.manualProtocolVersion       =ensureScalar({temp.manualVersion});
out.autoProtocolVersion         =ensureScalar({temp.autoVersion});
out.protocolDate                =datenum(reshape([temp.date],6,length(temp))')';
if bloat out.protocolAuthor     =ensureTypedVector({temp.author},'char'); end

out.correct                     =ensureScalar({trialRecords.correct});
if bloat out.subjectsInBox      =ensureTypedVector({trialRecords.subjectsInBox},'cell'); end %ensure vector cells of chars?
out.trialManagerClass           =ensureTypedVector({trialRecords.trialManagerClass},'char');
if bloat out.stimManagerClass   =ensureTypedVector({trialRecords.stimManagerClass},'char'); end
if bloat out.schedulerClass     =ensureTypedVector({trialRecords.schedulerClass},'char'); end
if bloat out.criterionClass     =ensureTypedVector({trialRecords.criterionClass},'char'); end
if bloat out.reinforcementManagerClass  =ensureTypedVector({trialRecords.reinforcementManagerClass},'char'); end
out.scaleFactor                 =ensureEqualLengthVects({trialRecords.scaleFactor});
if bloat out.type               ={trialRecords.type}; end %ensure type check?
out.targetPorts                 =ensureTypedVector({trialRecords.targetPorts},'index');
out.distractorPorts             =ensureTypedVector({trialRecords.distractorPorts},'index');

out.response                    =ensureScalar(cellfun(@encodeResponse,{trialRecords.response},out.targetPorts,out.distractorPorts,num2cell(out.correct),'UniformOutput',false));
if any(out.response==0)
    error('got zero response')
end

out.containedManualPokes        =ensureScalar({trialRecords.containedManualPokes});
if ismember('didHumanResponse',fieldnames(trialRecords))
    out.didHumanResponse        =ensureScalar({trialRecords.didHumanResponse});
else
    out.didHumanResponse        =ensureScalar(num2cell(nan*zeros(1,length(trialRecords))));
end
out.containedForcedRewards      =ensureScalar({trialRecords.containedForcedRewards});
out.didStochasticResponse       =ensureScalar({trialRecords.didStochasticResponse});

verifyAllFieldsNCols(out,length(trialRecords));
end

function out=encodeResponse(resp,targs,dstrs,correct)
if islogical(resp)
    if isscalar(find(resp))
        out=find(resp);
    else
        out=-1; %multiple blocked ports
    end
elseif ischar(resp)
    switch resp
        case 'none'
            out=-2;
        case 'manual kill'
            out=-3;
        case 'shift-2 kill'
            out=-4;
        case 'server kill'
            out=-5;
        otherwise
            out=-6;
            resp
            warning('unrecognized response')
    end
else
    resp
    class(resp)
    error('unrecognized response type')
end

if ismember(out,targs) == correct
    %pass
else
    error('bad correct calc')
end

if all(isempty(intersect(dstrs,targs)))
    %pass
else
    error('found intersecting targets and distractors')
end

end