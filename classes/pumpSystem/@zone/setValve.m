function setValve(z,valve,state)
lptWriteBit(valve{1},valve{2},state);
    WaitSecs(z.valveDelay);