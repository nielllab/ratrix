%% octoRetinotopy.m
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
%   each spot. This is analogous to a population vector code for screen position.
%   The response amplitude is used to modulate the color brightness, so bright pixels
%   have strong retinotopic tuning and dim pixels have weak tuning.
%
% This script is called as a script (not a function), reading/writing the
% calling workspace directly.
%
% REQUIRED WORKSPACE VARIABLES:
%   trialmean    - [Y x X x nTrials] pixel-wise mean dF/F per trial
%   stimOrder    - [1 x nTrials] stimulus condition index per trial
%   nrow         - number of rows in the spot grid (e.g., 4 for 6x4)
%   ncol         - number of columns in the spot grid (e.g., 6 for 6x4)
%   meanGreenImg - [Y x X x 3] normalized green anatomy RGB image
%   psfile       - (optional) path to PostScript output file
%
% OUTPUTS (returned to calling workspace):
%   xpolarImg    - {1 x 2} cell: HSV color images of azimuth (X) map per rep
%   ypolarImg    - {1 x 2} cell: HSV color images of elevation (Y) map per rep
%   topoOverlayImg - {1 x 2} cell: anatomy image with retinotopy amplitude overlay
%   topoAmpImg   - {1 x 2} cell: retinotopy response amplitude images per rep
%   xphase       - {1 x 2} cell: raw azimuth preference maps (float, position units)
%   yphase       - {1 x 2} cell: raw elevation preference maps (float, position units)
%
% FIGURES PRODUCED (printed to psfile):
%   Rep 1 (OFF):
%     Retinotopy X Map (OFF): HSV color image of azimuth preference, OFF response
%     Retinotopy Y Map (OFF): HSV color image of elevation preference, OFF response
%   Rep 2 (ON):
%     Retinotopy X Map (ON):  Same for ON responses
%     Retinotopy Y Map (ON):  Same for ON responses

%% --- Set up spot grid parameters ---

szx = ncol;    % number of spot columns (horizontal positions)
szy = nrow;    % number of spot rows (vertical positions)

% Spatial smoothing kernel applied to trial means before computing maps.
% Gaussian with 10x10 pixel kernel, sigma=1 pixel.
filt = fspecial('gaussian', [10 10], 1);
trialmeanfilt = imfilter(trialmean, filt);

% Total number of stimulus conditions: each spot location has an OFF and ON version
nstim = 2 * szx * szy;
nloc  = szx * szy;      % number of unique spatial locations

% Build vectors mapping each stimulus condition to its screen position.
% x: horizontal position (1 to szx, repeated szy times per column)
% y: vertical position (1 to szy, cycling through rows per column)
% onoff: 0 = OFF stimulus, 1 = ON stimulus
x = ones(nstim, 1);
y = ones(nstim, 1);
onoff = ones(nstim, 1); onoff(1:nloc) = 0;   % first nloc = OFF, second nloc = ON

% Assign x-position for each condition (all conditions in the same column share x)
for xpos = 1:szx
    x(((xpos-1)*szy+1):(xpos*szy)) = xpos;
end
x(nloc + (1:nloc)) = x(1:nloc);   % ON conditions have same x as corresponding OFF

% Assign y-position for each condition (cycles through row indices within each column)
for ypos = 1:szy
    y(ypos:szy:end) = ypos;
end


%% --- Compute mean response image per condition ---

% For each of the nstim conditions, compute the mean pixel response across all
% presentations of that condition. Threshold at 0.025 to suppress noise.
clear meanImg
for i = 1:nstim
    meanImg(:,:,i) = mean(trialmeanfilt(:,:,stimOrder==i), 3, 'omitnan');
end
meanImg(meanImg < 0.025) = 0;   % zero out weak/noisy responses


%% --- Compute retinotopic maps for OFF (rep=1) and ON (rep=2) ---

for rep = 1:2

    % Label for this rep: OFF (rep=1) or ON (rep=2)
    if rep == 1; repLabel = 'OFF'; else; repLabel = 'ON'; end

    % Initialize weighted-sum accumulators
    xmap = 0;   % accumulates: sum(response * x_position) per pixel
    ymap = 0;   % accumulates: sum(response * y_position) per pixel

    % Select the stimulus condition indices for this rep:
    %   rep=1: OFF conditions (indices 1 to nloc)
    %   rep=2: ON conditions (indices nloc+1 to 2*nloc)
    onrange = nloc*(rep-1) + (1:nloc);

    % Weighted average of x and y positions across all spot locations.
    % Each pixel gets a preferred x (and y) as the response-weighted mean position.
    for i = onrange
        xmap = xmap + meanImg(:,:,i) * x(i);
        ymap = ymap + meanImg(:,:,i) * y(i);
    end

    % Total response amplitude per pixel (sum across all spot conditions)
    amp = sum(meanImg(:,:,onrange), 3);
    amp(amp <= 0) = 0.001;    % avoid division by zero

    % Normalize by total amplitude to get weighted average position
    ymap = ymap ./ amp;
    xmap = xmap ./ amp;

    % Normalize amplitude to [0, 1] for color brightness scaling
    amp = amp / 0.3;
    amp(amp > 1) = 1;

    topoAmp = amp;   % save amplitude image for overlay


    %% --- Build and plot X (azimuth) retinotopy map ---

    % Replace NaN values with 0 before colormap mapping
    xmap(isnan(xmap)) = 0;

    % Map x-position values to HSV colors:
    % Position range [1.5, szx-0.5] maps to full HSV cycle (hue = position).
    % Color is then weighted by response amplitude (dim = weak retinotopic tuning).
    xpolar = mat2im(xmap, hsv, [1.5 szx-0.5]);
    xpolar = xpolar .* repmat(amp, [1 1 3]);

    % ---- FIGURE: Retinotopy X Map (OFF or ON) ----
    % HSV color image of azimuth (horizontal position) preference.
    % Color = preferred screen x-position; Brightness = response amplitude.
    % Displayed at 2x resolution for visibility.
    topox = figure;
    imshow(imresize(xpolar, 2));
    title(sprintf('Retinotopy X Map (%s)', repLabel), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


    %% --- Build and plot Y (elevation) retinotopy map ---

    ymap(isnan(ymap)) = 0;

    % Map y-position values to HSV colors (same approach as x-map)
    ypolar = mat2im(ymap, hsv, [1.5 szy-0.5]);
    ypolar = ypolar .* repmat(amp, [1 1 3]);

    % ---- FIGURE: Retinotopy Y Map (OFF or ON) ----
    % HSV color image of elevation (vertical position) preference.
    % Color = preferred screen y-position; Brightness = response amplitude.
    topoy = figure;
    imshow(imresize(ypolar, 2));
    title(sprintf('Retinotopy Y Map (%s)', repLabel), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


    %% --- Build anatomy overlay image ---
    % Creates a version of the green anatomy image where pixels with strong
    % retinotopic responses are highlighted (red and blue channels suppressed).
    % This shows where in the tissue the retinotopic signal is strongest.

    xphase{rep} = xmap;    % save raw position map
    yphase{rep} = ymap;

    overlay = meanGreenImg;
    % Suppress red and blue channels in proportion to retinotopic amplitude:
    % Bright retinotopy -> anatomy looks more green/pure; weak -> normal anatomy.
    overlay(:,:,1) = overlay(:,:,1) .* (1 - topoAmp).^2;   % reduce red
    overlay(:,:,3) = overlay(:,:,3) .* (1 - topoAmp).^2;   % reduce blue

    % Store outputs for use in the calling script's retinotopy summary panels
    xpolarImg{rep}     = xpolar;    % azimuth color map image
    ypolarImg{rep}     = ypolar;    % elevation color map image
    topoOverlayImg{rep} = overlay;  % anatomy with retinotopy overlay
    topoAmpImg{rep}    = topoAmp;   % amplitude image

end  % end rep loop (OFF / ON)
