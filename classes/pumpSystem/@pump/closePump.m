function p=closePump(p)

ensurePumpStopped(p);
if ~p.pumpOpen
    warning('pump not open')
end
fprintf('closing pump serial connection\n')
fclose(p.serialPort);
p.pumpOpen=0;

closeAllSerials;