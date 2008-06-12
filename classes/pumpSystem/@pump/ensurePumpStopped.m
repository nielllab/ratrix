function ensurePumpStopped(p)
if motorRunning(p)
    warning('pump motor running -- or pump has lost power and motor running bit got tripped')
end