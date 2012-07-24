function setLaser(s,state)
    pp(uint8(s.laserPin),state,[],[],s.decPPortAddr); %probably recast to hex
end