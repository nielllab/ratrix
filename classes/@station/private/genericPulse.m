function genericPulse(s,pins)

	if strcmp(s.responseMethod,'parallelPort')
		if ~isempty(pins)
			state=false*ones(1,length(pins.pinNums));
			state(pins.invs)=~state(pins.invs);
			lptWriteBits(pins.decAddr,pins.bitLocs,state);
			lptWriteBits(pins.decAddr,pins.bitLocs,~state);
		end
	end