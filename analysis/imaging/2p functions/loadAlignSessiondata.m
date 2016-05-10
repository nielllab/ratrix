display(sprintf('loading %s',sessionName{session}))
load(filename{session},'cfg','meanImg','greenframe','cycLength','dt');
if ~exist('cfg','var') | ~isfield(cfg,'saveDF') | cfg.saveDF==1
    display('loading dfofinterp')
    tic
    load(filename{session},'dfofInterp')
    toc
else
    get2pSession_sbx;
end
nframes = size(dfofInterp,3);
F = (1 + dfofInterp).* repmat(meanImg,[1 1 size(dfofInterp,3)]);  %%% reconstruct F from dF/F
F=  circshift(F, -[shiftx(session) shifty(session) 0]);  %%% shift to standard coordinates
meanShiftImg = circshift(meanImg,-[shiftx(session) shifty(session) ]);