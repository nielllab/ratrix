%% get2pSession_sbx_DR.m  v1.2 — 2026-05-19
% Loads or creates 2-photon session data from an .sbx file.
%
% PURPOSE:
%   If fileName points to a previously saved .mat session file, loads it directly.
%   If fileName points to an .sbx raw data file, calls get2pdata_sbx to extract
%   dF/F, timing, and reference images, then optionally saves the session .mat.
%   After loading, exports 3 diagnostic figures to the PDF.
%
% CHANGELOG:
%   v1.2 (2026-05-19): Fixed "Integer operands required for colon operator" warnings
%     in cycle average loop. cycLength/dt is now computed once as round(cycLength/dt)
%     and stored in nCycFrames, which is used for both the loop bound and the stride.
%   v1.1 (2026-05-19): Added figNum labeling to all 3 exported figures (baseline
%     image, mean timecourse, cycle average). Previously these were the first 3 PDF
%     pages but carried no Fig N label, causing all subsequent pages to be mis-numbered.
%   v1.0: Original version (no version header).
%
% This script is called as a script (not a function), reading/writing the
% calling workspace directly.
%
% REQUIRED WORKSPACE VARIABLES:
%   cfg       - config struct; cfg.alignData, cfg.spatialBin, cfg.temporalBin, etc.
%   dt        - temporal resampling interval (seconds per frame)
%   figNum    - integer figure counter (incremented here for each exported figure)
%   psfile    - (optional) path to output PDF file for appending
%   fileName  - (optional) full path to .sbx or .mat file; prompted if absent
%   sessionName - (optional) output path for saving session .mat; prompted if absent
%
% OUTPUTS (returned to calling workspace):
%   dfofInterp  - [Y x X x T] dF/F movie, temporally resampled
%   phasetimes  - [1 x nStims] stimulus onset times (seconds)
%   meanImg     - [Y x X] baseline fluorescence image
%   greenframe  - raw green channel reference frame
%   dt          - (possibly updated) resampling interval
%   figNum      - updated figure counter (incremented by 2 or 3)
%
% FIGURES EXPORTED (2 or 3):
%   Fig N  : Baseline (median) image         — skipped if meanImg unavailable
%   Fig N+1: Mean dF/F timecourse
%   Fig N+2: Cycle average timecourse
%
%%% creates session data or reads previously generated session data

if~isfield(cfg,'alignData')
    cfg.alignData = 1;
end

if ~exist('fileName','var')

    [f p] = uigetfile({'*.mat;*.sbx'},'.mat or .tif file');
    fileName = fullfile(p,f)
end

if strcmp(fileName(end-3:end),'.mat') %%% previously generated
    display('loading data')
    load(fileName)
    display('done')
    if ~exist('cycLength','var')
        cycLength=8;
    end

else %%% new session data

    fileName = fileName(1:end-4)  %%% create filename

    if ~exist('cycLength','var')
        cycLength= 2;
    end

    %     twocolor = input('# of channels : ')
    %     twocolor= (twocolor==2);
    %
    twocolor=0;

    if twocolor
        [dfofInterp dtRaw redframe greenframe] = get2colordata(fileName,dt,cycLength,cfg); %%% not currently functional!
    else
        [dfofInterp dtRaw greenframe framerate phasetimes meanImg dt vidframetimes] = get2pdata_sbx(fileName,dt,cycLength,cfg);
    end


    if ~exist('sessionName','var')
        [fs ps] = uiputfile('*.mat','session data');
        sessionName= fullfile(ps,fs);
    end
    if ~iscell(sessionName) && sessionName(1)~=0
        display('saving data')

        tic
        if twocolor
            save(sessionName,'dfofInterp','cycLength','redframe','greenframe','-v7.3');
        else
            save(sessionName,'cycLength','greenframe','phasetimes','meanImg','dt','cfg','-v7.3');
            if cfg.saveDF==1
                save(sessionName,'dfofInterp','-append');
            end
        end
        toc
        display('done')
    end
end

% Ensure the output directory for psfile exists before first exportgraphics call
if exist('psfile','var')
    psdir = fileparts(psfile);
    if ~isempty(psdir) && ~exist(psdir,'dir')
        mkdir(psdir);
    end
end

% If meanImg was not saved in the session .mat (e.g. created by an older version
% of this script), compute it from dfofInterp as a fallback.
if ~exist('meanImg','var') && exist('dfofInterp','var')
    meanImg = mean(dfofInterp, 3, 'omitnan');
end

if exist('meanImg','var')
    m= meanImg;
    upper = prctile(m(:),97.5)*1.2;
    lower = min(m(:));
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Baseline Image', figNum));
    imagesc(m,[lower upper]); colormap gray; axis equal
    % Use 'none' interpreter to avoid backslashes in file path being read as LaTeX
    title(sprintf('Fig %d: %s baseline (median) img', figNum, fileName), 'Interpreter', 'none');

    if exist('psfile','var')
        exportgraphics(gcf, psfile, 'Append', true);
    end
else
    warning('get2pSession_sbx_DR: meanImg not found and could not be computed — baseline image figure skipped.');
end

figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Mean Timecourse', figNum));
plot((1:size(dfofInterp,3))*dt,squeeze(mean(mean(dfofInterp,2),1)));
xlabel('secs');
title(sprintf('Fig %d: %s mean timecourse', figNum, fileName), 'Interpreter', 'none');

if exist('psfile','var')
    exportgraphics(gcf, psfile, 'Append', true);
end

clear cycAvg
nCycFrames = round(cycLength/dt);   % integer # of frames per cycle
for i = 1:nCycFrames;
    cycAvg(i) = mean(mean(mean(dfofInterp(:,:,i:nCycFrames:end))));
end
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Cycle Average', figNum));
plot((1:length(cycAvg))*dt,cycAvg); xlabel('secs');
title(sprintf('Fig %d: %s cycle average', figNum, fileName), 'Interpreter', 'none');

if exist('psfile','var')
    exportgraphics(gcf, psfile, 'Append', true);
end
