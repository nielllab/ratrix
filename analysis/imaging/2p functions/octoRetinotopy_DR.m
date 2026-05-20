%% octoRetinotopy_DR.m  v1.1 — 2026-05-19
% Computes and plots retinotopic maps from spot stimulus data (6x4 or 5x5 grid).
%
% PURPOSE:
%   Given pixel-wise mean responses to a grid of OFF and ON spot stimuli,
%   computes a weighted-average retinotopic map showing which screen position
%   each image pixel responds to most strongly.
%   Produces separate azimuth (X) and elevation (Y) maps for OFF and ON responses.
%
% ALGORITHM:
%   For each image pixel, the preferred X and Y screen position is computed as a
%   weighted average of all spot positions, where weights = mean pixel response to
%   each spot. The response amplitude modulates color brightness, so bright pixels
%   have strong retinotopic tuning and dim pixels have weak tuning.
%
% This script is called as a script (not a function), reading/writing the
% calling workspace directly.
%
% REQUIRED WORKSPACE VARIABLES:
%   figNum       - integer figure counter. On entry, figNum is already set to the
%                  value for this script's first exported figure (caller pre-increments).
%                  This script increments figNum for each of its 4 exports.
%   trialmean    - [Y x X x nTrials] pixel-wise mean dF/F per trial
%   stimOrder    - [1 x nTrials] stimulus condition index per trial
%   nrow         - number of rows in the spot grid (e.g., 4 for 6x4)
%   ncol         - number of columns in the spot grid (e.g., 6 for 6x4)
%   meanGreenImg - [Y x X x 3] normalized green anatomy RGB image
%   psfile       - (optional) path to output PDF file for appending
%
% OUTPUTS (returned to calling workspace):
%   xpolarImg      - {1x2} HSV color images of azimuth (X) map, one per rep
%   ypolarImg      - {1x2} HSV color images of elevation (Y) map, one per rep
%   topoOverlayImg - {1x2} anatomy image with retinotopy amplitude overlay
%   topoAmpImg     - {1x2} retinotopy response amplitude images per rep
%   xphase         - {1x2} raw azimuth preference maps (float, position units)
%   yphase         - {1x2} raw elevation preference maps (float, position units)
%   figNum         - updated figure counter (incremented by 4)
%
% FIGURES EXPORTED (4 total — 2 per rep):
%   Fig N  : Retinotopy X Map (OFF) — azimuth preference, OFF response
%   Fig N+1: Retinotopy Y Map (OFF) — elevation preference, OFF response
%   Fig N+2: Retinotopy X Map (ON)  — azimuth preference, ON response
%   Fig N+3: Retinotopy Y Map (ON)  — elevation preference, ON response
%
% figNum SCHEME:
%   This script increments figNum for each of its 4 exports. On entry, figNum
%   should be at the last exported figure from the calling script. This script
%   does NOT expect the caller to pre-increment — it owns all its own increments.
%   Caller does NOT advance figNum after this call.

%% --- Set up spot grid parameters ---

szx = ncol;   % number of spot columns (horizontal positions)
szy = nrow;   % number of spot rows (vertical positions)

% Spatial smoothing applied to trial means before computing maps
filt = fspecial('gaussian', [10 10], 1);
trialmeanfilt = imfilter(trialmean, filt);

nstim = 2 * szx * szy;   % total conditions: each location has OFF and ON
nloc  = szx * szy;        % number of unique spatial locations

% Build vectors mapping each stimulus condition to its screen position
x     = ones(nstim, 1);
y     = ones(nstim, 1);
onoff = ones(nstim, 1); onoff(1:nloc) = 0;   % first nloc = OFF, second = ON

for xpos = 1:szx
    x(((xpos-1)*szy+1):(xpos*szy)) = xpos;
end
x(nloc + (1:nloc)) = x(1:nloc);   % ON conditions share x with corresponding OFF

for ypos = 1:szy
    y(ypos:szy:end) = ypos;
end


%% --- Compute mean response image per condition ---

clear meanImg
for i = 1:nstim
    meanImg(:,:,i) = mean(trialmeanfilt(:,:,stimOrder==i), 3, 'omitnan');
end
meanImg(meanImg < 0.025) = 0;   % suppress weak/noisy responses


%% --- Compute retinotopic maps for OFF (rep=1) and ON (rep=2) ---

for rep = 1:2

    if rep == 1; repLabel = 'OFF'; else; repLabel = 'ON'; end

    % Weighted-average x and y screen position across all spot locations
    xmap    = 0;
    ymap    = 0;
    onrange = nloc*(rep-1) + (1:nloc);

    for i = onrange
        xmap = xmap + meanImg(:,:,i) * x(i);
        ymap = ymap + meanImg(:,:,i) * y(i);
    end

    % Normalize by total amplitude
    amp        = sum(meanImg(:,:,onrange), 3);
    amp(amp <= 0) = 0.001;
    ymap       = ymap ./ amp;
    xmap       = xmap ./ amp;

    % Normalize amplitude to [0, 1] for color brightness scaling
    amp        = amp / 0.3;
    amp(amp > 1) = 1;
    topoAmp    = amp;

    % ---- FIGURE: Retinotopy X Map (Fig N) ----
    % HSV color image of azimuth (horizontal screen position) preference.
    % Color = preferred x-position; Brightness = response amplitude.
    xmap(isnan(xmap)) = 0;
    xpolar = mat2im(xmap, hsv, [1.5 szx-0.5]);
    xpolar = xpolar .* repmat(amp, [1 1 3]);

    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Retinotopy X Map (%s)', figNum, repLabel));
    imshow(imresize(xpolar, 2));
    title(sprintf('Fig %d: Retinotopy X Map (%s)', figNum, repLabel), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE: Retinotopy Y Map (Fig N+1) ----
    % HSV color image of elevation (vertical screen position) preference.
    ymap(isnan(ymap)) = 0;
    ypolar = mat2im(ymap, hsv, [1.5 szy-0.5]);
    ypolar = ypolar .* repmat(amp, [1 1 3]);

    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Retinotopy Y Map (%s)', figNum, repLabel));
    imshow(imresize(ypolar, 2));
    title(sprintf('Fig %d: Retinotopy Y Map (%s)', figNum, repLabel), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Build anatomy overlay (green channel with retinotopy amplitude highlight)
    xphase{rep} = xmap;
    yphase{rep} = ymap;

    overlay = meanGreenImg;
    overlay(:,:,1) = overlay(:,:,1) .* (1 - topoAmp).^2;
    overlay(:,:,3) = overlay(:,:,3) .* (1 - topoAmp).^2;

    xpolarImg{rep}      = xpolar;
    ypolarImg{rep}      = ypolar;
    topoOverlayImg{rep} = overlay;
    topoAmpImg{rep}     = topoAmp;

end  % end rep loop (OFF / ON)
