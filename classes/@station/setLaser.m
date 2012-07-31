function setLaser(s,state)
    pp(s.laserPins.pinNums,repmat(state,1,length(s.laserPins)),false,[],s.laserPins.decAddr);
end