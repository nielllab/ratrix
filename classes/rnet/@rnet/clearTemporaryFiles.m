function clearTemporaryFiles(r)
fout = sprintf('.tmp-java-matlab-%d-*-*-outgoing.mat',r.type);
fin = sprintf('.tmp-java-%d-*-*-incoming.mat',r.type);
foutpath = fullfile(matlabroot,fout);
finpath = fullfile(matlabroot,fin);
if IsWin
    dos(sprintf('del %s',foutpath));
    dos(sprintf('del %s',finpath));
elseif IsOSX
    system(sprintf('rm %s',foutpath));
    system(sprintf('rm %s',finpath));
else
    error('In clearTemporaryFiles(): Unsupported OS');
end