function setLaser(s,state)
if ~isempty(s.laserPins)
    pp(s.laserPins.pinNums,repmat(state,1,length(s.laserPins)),false,[],s.laserPins.decAddr);
end
end