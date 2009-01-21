function subject=setUpOrStopDatanet(subject,flag,data)

subject.protocol=setUpOrStopDatanet(subject.protocol,subject.trainingStepNum,flag,data);
%note: technically this is a "change to the protocol" but (conveniently) we do not increase the the
%counter of the manual version or autoversion via setProtocolAndStep

