if session>0
    mergeSess=session;
end
display(sprintf('loading %s',sessionName{mergeSess}))
clear cfg meanImg greenframe cycLength dt sbxfilename
load(filename{mergeSess},'cfg','meanImg','greenframe','cycLength','dt','sbxfilename');

if ~exist('cfg','var') | ~isfield(cfg,'saveDF') | cfg.saveDF==1
    display('loading dfofinterp')
    tic
    load(filename{mergeSess},'dfofInterp')
    toc
else
    sprintf('need to load sbx file for %s',sessionName{mergeSess})
    clear fileName
    if exist('sbxfilename','var')
        fileName = sbxfilename;
    end
    get2pSession_sbx;
    
end
nframes = size(dfofInterp,3);
%F = (1 + dfofInterp).* repmat(meanImg,[1 1 size(dfofInterp,3)]);  %%% reconstruct F from dF/F
F= dfofInterp;
F=  circshift(F, -[shiftx(mergeSess) shifty(mergeSess) 0]);  %%% shift to standard coordinates
meanShiftImg = circshift(meanImg,-[shiftx(mergeSess) shifty(mergeSess) ]);