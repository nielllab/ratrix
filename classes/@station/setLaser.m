function setLaser(s,state)
    pp(s.laserPins,repmat(state,1,length(s.laserPins)),false,[],s.decPPortAddr); %does this work when pins is empty?
end