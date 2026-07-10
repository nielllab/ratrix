%% mapGratingsOcto.m
% Computes and plots grating orientation preference maps for octopus optic lobe data.
%
% PURPOSE:
%   Given pixel-wise mean responses to grating stimuli, produces:
%   (1) A pixel-wise color map showing horizontal vs. vertical grating preference.
%   (2) An overlay of the cyclic phase polar map with the green anatomy channel.
%   Also computes a raw cycle-amplitude image (not printed) as an intermediate step.
%
% This script is called as a script (not a function), reading/writing the
% calling workspace directly.
%
% ALGORITHM:
%   - Averages pixel responses to horizontal gratings (conditions 1 and 7)
%     and vertical gratings (conditions 4 and 10) after Gaussian smoothing.
%   - Constructs an RGB image where R = horizontal response, G = vertical response.
%     Normalizes so that the maximum response across R/G/B does not exceed 1.
%   - Constructs a phase/anatomy overlay by blending the cyclic phase polar image
%     (cycPolarImg) with the green anatomy image (meanGreenImg).
%
% REQUIRED WORKSPACE VARIABLES:
%   trialmean    - [Y x X x nTrials] pixel-wise mean dF/F per trial
%   stimOrder    - [1 x nTrials] stimulus condition index per trial
%   cycAmp       - [Y x X] cycle-average response amplitude image (from main script)
%   cycPolarImg  - [Y x X x 3] cyclic phase polar map (HSV color, from main script)
%   meanGreenImg - [Y x X x 3] normalized green anatomy RGB image
%   psfile       - (optional) path to PostScript output file
%
% OUTPUTS (returned to calling workspace):
%   hvImg      - [Y x X x 3] RGB image of horizontal vs. vertical grating preference
%   overlayImg - [Y x X x 3] blended phase polar map + anatomy overlay image

%% --- Spatial smoothing ---

% Apply Gaussian smoothing to reduce pixel-wise noise before computing preference maps.
% Kernel: 10x10 pixels, sigma=1 pixel.
filt = fspecial('gaussian', [10 10], 1);
trialmeanfilt = imfilter(trialmean, filt);

%% --- Compute mean responses for each grating type ---

% Average responses to horizontal gratings (stimulus conditions 1 and 7).
% These correspond to two different temporal/spatial frequency horizontal grating conditions.
horiz  = mean(trialmeanfilt(:,:,stimOrder==1 | stimOrder==7), 3, 'omitnan');

% Average responses to vertical gratings (stimulus conditions 4 and 10).
vert   = mean(trialmeanfilt(:,:,stimOrder==4 | stimOrder==10), 3, 'omitnan');

% Average responses to flicker (stimulus conditions 4 and 13).
% Note: condition 4 appears in both vert and flicker; this is intentional in the original.
flicker = mean(trialmeanfilt(:,:,stimOrder==4 | stimOrder==13), 3, 'omitnan');


%% --- Cycle amplitude figure (not printed) ---

% ---- FIGURE (not printed): Cycle Amplitude Map ----
% Raw grayscale image of cycAmp (the periodic response amplitude computed in the
% main script). Used for visual inspection; not saved to PDF.
figure
imagesc(cycAmp);   % amplitude from cycle-average map


%% --- Horizontal vs. Vertical Grating Preference Map ---

% Construct an RGB image where:
%   Red channel   = horizontal grating response
%   Green channel = vertical grating response
%   Blue channel  = (unused, set to zero)
% Pixels that respond more to horizontal gratings appear red;
% pixels that respond more to vertical gratings appear green.

maxdf = 0.05;   % normalization scale (expected max dF/F)

hvv = zeros(size(horiz,1), size(horiz,2), 3);
hvv(:,:,1) = horiz;    % Red channel = horizontal grating response
hvv(:,:,2) = vert;     % Green channel = vertical grating response
% hvv(:,:,3) = flicker;  % Blue channel = flicker (currently unused/commented out)
hvv = hvv / maxdf;     % normalize to [0, 1] range

% Find the maximum response across channels per pixel.
% Normalize pixels where any channel exceeds 1 (prevents color saturation artifacts
% in pixels with very high responses in both orientations).
maxval = max(hvv, [], 3);
normalizer = ones(size(maxval));
normalizer(maxval > 1) = maxval(maxval > 1);   % only normalize pixels above 1

% Clip negatives and apply per-pixel normalizer
hvv(hvv < 0) = 0;
hvv = hvv ./ repmat(normalizer, [1 1 3]);

% ---- FIGURE: Horizontal vs. Vertical Grating Preference Map ----
% RGB image where R = horizontal response, G = vertical response.
% Pure red = strongly horizontal; pure green = strongly vertical;
% yellow = responds equally to both.
figure
imshow(hvv);
hvImg = hvv;   % save for return to calling workspace
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% --- Phase Polar Map / Anatomy Overlay ---

% Compute a mean response amplitude image across all three grating types.
% Used as a weight for the overlay, but not used in the actual overlay computation below.
amp = (horiz + flicker + vert) / 3;
amp = amp / maxdf;
amp(amp < 0) = 0;
amp(amp > 1) = 1;

% Blend the green anatomy image with the cyclic phase polar map (cycPolarImg).
% Weighting: 2/3 anatomy + 1/3 cyclic phase. This shows where periodic responses
% are located within the tissue context.
overlay = 0.66 * meanGreenImg + 0.33 * cycPolarImg;

% ---- FIGURE: Cycle Phase / Green Channel Overlay ----
% Blended image of green anatomy and cyclic phase polar map.
% Shows the spatial relationship between anatomy structure and periodic response phase.
figure
imshow(overlay)
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% Save overlay image for return to calling workspace
overlayImg = overlay;
