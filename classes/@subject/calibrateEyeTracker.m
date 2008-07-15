function subject=calibrateEyeTracker(subject)

subject.protocol=calibrateEyeTracker(subject.protocol,subject.trainingStepNum);
%note: technically this is a "change to the protocol" but (conveniently) we do not increase the the
%counter of the manual version or autoversion via setProtocolAndStep

