function [meanpolar,ypts,xpts] = do_topo()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    warning off

    % get tif file locations 
    batchThresholdExpts % uncomment recording session in batch file
    cd(pathname)

    % select the fields that you want to filter on
    alluse = find(strcmp({files.subj},'G6H305RT')...
          & strcmp({files.expt},'081921'));


    % temp file needs to exist for some reason
    psfilename = fullfile(pathname,'tempWF.ps'); 
    if exist(psfilename,'file')==2;delete(psfilename);end   

    % run doTopography 
    % (use this one to average all sessions that meet criteria)
    length(alluse)
    allsubj = unique({files(alluse).subj})

    for s=1:1

        use = alluse;
            allsubj{s}

        % calculate gradients and regions
        clear map merge

        x0=0; y0=0; sz=128;
        doTopography;

    end

end

