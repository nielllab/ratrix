function lineProfileApp(preBase, postBase, varargin)
%LINEPROFILEAPP  Compare intensity along a line in two z-stacks (e.g. pre vs post).
%
%   lineProfileApp
%       Asks you to pick a channel tif for each stack.
%   lineProfileApp(preBase, postBase)
%       preBase / postBase are file paths WITHOUT the _1.tif / _2.tif ending,
%       e.g. 'D:\data\100226_ASW150E24_000_007'.
%
%   Name-value options:
%     'DisplayRange'  [min max] for the picture only            (default [300 30000])
%     'File1IsRed'    true if the _1 file is red, false if _2   (default false)
%     'Names'         labels for the two frames                 (default {'Pre','Post'})
%
%   Click an image to place point 1, then point 2. Later clicks move the
%   nearest point. Profiles run from point 1 to point 2 and are compared as a
%   percent of each line, so the two lines may differ in length. Profile
%   values are the RAW tif values, not the display-scaled ones.
%
%   Needs MATLAB R2020b or newer (uifigure). No toolboxes required.

if nargin < 1, preBase = ''; end
if nargin < 2, postBase = ''; end
ip = inputParser;
addParameter(ip, 'DisplayRange', [300 30000]);
addParameter(ip, 'File1IsRed', false);
addParameter(ip, 'Names', {'Pre', 'Post'});
parse(ip, varargin{:});
opt = ip.Results;
nm = opt.Names;

%% state shared with the callbacks below
colImg = [1.00 0.69 0.18; 0.30 0.79 1.00];     % line colours drawn on the images
colPlot = [0.85 0.42 0.00; 0.00 0.45 0.74];    % trace colours in the plots
stk = struct('R', {[], []}, 'G', {[], []}, 'base', {'', ''});   % raw uint16 stacks
cur = struct('R', {[], []}, 'G', {[], []});    % 2-D images currently shown (double)
cache = struct('mode', {'', ''}, 'R', {[], []}, 'G', {[], []});% projection cache
zsel = [1 1];
pts = {zeros(0, 2), zeros(0, 2)};
prof = struct('v', {[], []}, 'sm', {[], []}, 'L', {NaN, NaN});
profX = [];

%% figure and layout
fig = uifigure('Name', 'Line profile comparison', 'Position', [40 40 1500 940]);
gl = uigridlayout(fig, [4 2]);
gl.RowHeight = {104, '1.3x', '1x', 116};
gl.ColumnWidth = {'1x', '1x'};
gl.Padding = [8 8 8 8];

% --- controls
gc = uigridlayout(gl, [2 11]);
place(gc, 1, [1 2]);
gc.RowHeight = {30, 30};
gc.ColumnWidth = {105, 105, 100, 80, 40, 80, 120, 150, 115, 100, 90};
gc.Padding = [4 4 4 4];

place(uibutton(gc, 'push', 'Text', ['Load ' lower(nm{1}) '...'], ...
    'ButtonPushedFcn', @(~, ~) loadFrame(1, '')), 1, 1);
place(uibutton(gc, 'push', 'Text', ['Load ' lower(nm{2}) '...'], ...
    'ButtonPushedFcn', @(~, ~) loadFrame(2, '')), 1, 2);
place(uilabel(gc, 'Text', 'Display min', 'HorizontalAlignment', 'right'), 1, 3);
edMin = place(uieditfield(gc, 'numeric', 'Value', opt.DisplayRange(1), ...
    'ValueChangedFcn', @(~, ~) refreshImages()), 1, 4);
place(uilabel(gc, 'Text', 'max', 'HorizontalAlignment', 'right'), 1, 5);
edMax = place(uieditfield(gc, 'numeric', 'Value', opt.DisplayRange(2), ...
    'ValueChangedFcn', @(~, ~) refreshImages()), 1, 6);
ddView = place(uidropdown(gc, 'Items', {'Composite', 'Red only', 'Green only'}, ...
    'ValueChangedFcn', @(~, ~) refreshImages()), 1, 7);
ddProj = place(uidropdown(gc, 'Items', {'Single plane', 'Max projection', 'Mean projection'}, ...
    'ValueChangedFcn', @(~, ~) onProj()), 1, 8);
cbLink = place(uicheckbox(gc, 'Text', 'Link z-planes', 'Value', true), 1, 9);
btnZoom = place(uibutton(gc, 'state', 'Text', 'Zoom / pan', ...
    'ValueChangedFcn', @(s, ~) setZoomMode(s.Value)), 1, 10);
place(uibutton(gc, 'push', 'Text', 'Fit view', 'ButtonPushedFcn', @(~, ~) fitAll()), 1, 11);

place(uilabel(gc, 'Text', 'Profile channel', 'HorizontalAlignment', 'right'), 2, 1);
ddChan = place(uidropdown(gc, 'Items', {'Green', 'Red'}, ...
    'ValueChangedFcn', @(~, ~) updateProfiles()), 2, 2);
place(uilabel(gc, 'Text', 'Band width (px)', 'HorizontalAlignment', 'right'), 2, 3);
spBand = place(uispinner(gc, 'Limits', [1 150], 'Value', 7, 'Step', 2, ...
    'RoundFractionalValues', 'on', 'ValueChangedFcn', @(~, ~) update()), 2, 4);
place(uilabel(gc, 'Text', 'by', 'HorizontalAlignment', 'center'), 2, 5);
ddAgg = place(uidropdown(gc, 'Items', {'Mean', 'Max'}, ...
    'ValueChangedFcn', @(~, ~) updateProfiles()), 2, 6);
place(uilabel(gc, 'Text', 'Smoothing (px)', 'HorizontalAlignment', 'right'), 2, 7);
spSmooth = place(uispinner(gc, 'Limits', [1 201], 'Value', 1, 'Step', 2, ...
    'RoundFractionalValues', 'on', 'ValueChangedFcn', @(~, ~) updateProfiles()), 2, 8);
cbDiff = place(uicheckbox(gc, 'Text', 'Show difference', 'Value', true, ...
    'ValueChangedFcn', @(~, ~) updateProfiles()), 2, 9);
place(uibutton(gc, 'push', 'Text', 'Clear lines', 'ButtonPushedFcn', @(~, ~) clearLines()), 2, 10);
place(uibutton(gc, 'push', 'Text', 'Export...', 'ButtonPushedFcn', @(~, ~) exportProfiles()), 2, 11);

% --- the two image panels
pnl = gobjects(1, 2);
ax = gobjects(1, 2);
hImg = gobjects(1, 2);
hBand = gobjects(1, 2);
hLine = gobjects(1, 2);
hPt = gobjects(1, 2);
hTxt = gobjects(2, 2);
lblZ = gobjects(1, 2);
sld = gobjects(1, 2);
lblInfo = gobjects(1, 2);
for k = 1:2
    pnl(k) = uipanel(gl, 'Title', nm{k});
    place(pnl(k), 2, k);
    gi = uigridlayout(pnl(k), [3 1]);
    gi.RowHeight = {'1x', 34, 22};
    gi.Padding = [4 4 4 4];
    gi.RowSpacing = 2;

    ax(k) = uiaxes(gi);
    place(ax(k), 1, 1);
    hImg(k) = image(ax(k), zeros(2, 2, 3));
    hold(ax(k), 'on');
    ax(k).Color = [0 0 0];
    ax(k).XTick = [];
    ax(k).YTick = [];
    ax(k).Box = 'on';
    ax(k).YDir = 'reverse';
    ax(k).DataAspectRatio = [1 1 1];
    try, ax(k).Toolbar.Visible = 'off'; catch, end %#ok<NOCOM>
    hBand(k) = patch(ax(k), 'XData', NaN, 'YData', NaN, 'FaceColor', colImg(k, :), ...
        'FaceAlpha', 0.15, 'EdgeColor', colImg(k, :), 'LineStyle', '--', ...
        'HitTest', 'off', 'PickableParts', 'none');
    hLine(k) = plot(ax(k), NaN, NaN, '-', 'Color', colImg(k, :), 'LineWidth', 1.5, ...
        'HitTest', 'off', 'PickableParts', 'none');
    hPt(k) = plot(ax(k), NaN, NaN, 'o', 'LineStyle', 'none', 'MarkerSize', 13, ...
        'MarkerFaceColor', colImg(k, :), 'MarkerEdgeColor', 'k', 'LineWidth', 1.5, ...
        'HitTest', 'off', 'PickableParts', 'none');
    for jj = 1:2
        hTxt(k, jj) = text(ax(k), NaN, NaN, num2str(jj), 'Color', 'k', 'FontWeight', 'bold', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'Visible', 'off', 'HitTest', 'off', 'PickableParts', 'none');
    end
    hImg(k).ButtonDownFcn = @(~, e) onImageClick(k, e);
    ax(k).ButtonDownFcn = @(~, e) onImageClick(k, e);

    gz = uigridlayout(gi, [1 2]);
    place(gz, 2, 1);
    gz.ColumnWidth = {80, '1x'};
    gz.Padding = [0 0 0 0];
    lblZ(k) = place(uilabel(gz, 'Text', 'z -'), 1, 1);
    sld(k) = place(uislider(gz, 'Limits', [1 2], 'Value', 1, 'MajorTicks', [], ...
        'MinorTicks', [], 'Enable', 'off', ...
        'ValueChangingFcn', @(~, e) onZ(k, e.Value), ...
        'ValueChangedFcn', @(~, e) onZ(k, e.Value)), 1, 2);

    lblInfo(k) = place(uilabel(gi, 'Text', '', 'FontColor', [0.35 0.35 0.35]), 3, 1);
end

% --- profile plots
gp = uigridlayout(gl, [2 1]);
place(gp, 3, [1 2]);
gp.RowHeight = {'2.2x', '1x'};
gp.Padding = [0 0 0 0];
gp.RowSpacing = 4;

axP = uiaxes(gp);
place(axP, 1, 1);
hP = gobjects(1, 2);
for k = 1:2
    hP(k) = plot(axP, NaN, NaN, 'LineWidth', 1.8, 'Color', colPlot(k, :), 'DisplayName', nm{k});
    hold(axP, 'on');
end
grid(axP, 'on');
box(axP, 'on');
xlabel(axP, 'Position along the line (% of line length)');
ylabel(axP, 'Raw intensity');
axP.XLim = [0 100];
legend(axP, hP, 'Location', 'northeast');

axD = uiaxes(gp);
place(axD, 2, 1);
hold(axD, 'on');
hDpos = patch(axD, 'XData', NaN, 'YData', NaN, 'FaceColor', colPlot(2, :), ...
    'FaceAlpha', 0.5, 'EdgeColor', 'none');
hDneg = patch(axD, 'XData', NaN, 'YData', NaN, 'FaceColor', colPlot(1, :), ...
    'FaceAlpha', 0.5, 'EdgeColor', 'none');
hDline = plot(axD, NaN, NaN, 'k', 'LineWidth', 1);
grid(axD, 'on');
box(axD, 'on');
xlabel(axD, 'Position along the line (% of line length)');
ylabel(axD, [nm{2} ' - ' nm{1}]);
axD.XLim = [0 100];

% --- stats table
tbl = uitable(gl);
place(tbl, 4, [1 2]);
tbl.ColumnName = {'Line', 'Points (x, y in px)', 'Length (px)', 'Mean', 'Peak', 'Integrated (mean x length)'};
tbl.RowName = {};
tbl.ColumnWidth = {130, 260, 100, 100, 160, 180};
tbl.Data = cell(3, 6);

%% start up
setZoomMode(false);
updateHints();
if nargin >= 2 && ~isempty(preBase) && ~isempty(postBase)
    loadFrame(1, preBase);
    loadFrame(2, postBase);
elseif nargin == 0
    loadFrame(1, '');
    loadFrame(2, '');
end


%% ===================== nested callbacks (share the state above) =====================

    function loadFrame(i, base)
        if nargin < 2 || isempty(base)
            [f, p] = uigetfile({'*_1.tif;*_2.tif', 'Channel stacks (*_1.tif, *_2.tif)'; ...
                '*.tif;*.tiff', 'All TIFFs'}, ['Select a channel tif for ' nm{i}]);
            if isequal(f, 0), return; end
            base = fullfile(p, regexprep(f, '_[12]\.tif$', '', 'ignorecase'));
        end
        f1 = [base '_1.tif'];
        f2 = [base '_2.tif'];
        if ~isfile(f1) || ~isfile(f2)
            uialert(fig, sprintf('Could not find both channel files:\n%s\n%s', f1, f2), 'Missing files');
            return
        end
        dlg = uiprogressdlg(fig, 'Title', 'Loading', 'Indeterminate', 'on', ...
            'Message', ['Reading ' nm{i} ' stacks...']);
        try
            c1 = readTifStack(f1);
            c2 = readTifStack(f2);
        catch ME
            close(dlg);
            uialert(fig, ME.message, 'Could not read tif');
            return
        end
        close(dlg);
        if ~isequal(size(c1), size(c2))
            uialert(fig, 'The _1 and _2 stacks have different sizes.', 'Size mismatch');
            return
        end
        if opt.File1IsRed
            stk(i).R = c1;
            stk(i).G = c2;
        else
            stk(i).R = c2;
            stk(i).G = c1;
        end
        stk(i).base = base;
        nz = size(stk(i).R, 3);
        sld(i).Value = 1;
        sld(i).Limits = [1 max(nz, 2)];
        zsel(i) = max(1, round(nz / 2));
        sld(i).Value = zsel(i);
        if nz < 2, sld(i).Enable = 'off'; else, sld(i).Enable = 'on'; end
        pts{i} = zeros(0, 2);
        cache(i).mode = '';
        [~, tagName] = fileparts(base);
        pnl(i).Title = sprintf('%s: %s  (%d planes, %d x %d px)', nm{i}, tagName, nz, ...
            size(stk(i).R, 1), size(stk(i).R, 2));
        updateCur(i);
        refreshImages();
        fitView(i);
        if ~isempty(stk(1).R) && ~isempty(stk(2).R)
            cbLink.Value = size(stk(1).R, 3) == size(stk(2).R, 3);
        end
        update();
    end

    function updateCur(i)
        if isempty(stk(i).R), return; end
        nz = size(stk(i).R, 3);
        z = min(max(zsel(i), 1), nz);
        pm = ddProj.Value;
        if strcmp(pm, 'Single plane')
            cur(i).R = double(stk(i).R(:, :, z));
            cur(i).G = double(stk(i).G(:, :, z));
            lblZ(i).Text = sprintf('z %d / %d', z, nz);
        else
            if ~strcmp(cache(i).mode, pm)
                if strcmp(pm, 'Max projection')
                    cache(i).R = double(max(stk(i).R, [], 3));
                    cache(i).G = double(max(stk(i).G, [], 3));
                else
                    cache(i).R = mean(stk(i).R, 3);
                    cache(i).G = mean(stk(i).G, 3);
                end
                cache(i).mode = pm;
            end
            cur(i).R = cache(i).R;
            cur(i).G = cache(i).G;
            lblZ(i).Text = 'projection';
        end
    end

    function refreshImages()
        lo = edMin.Value;
        hi = edMax.Value;
        if hi <= lo, hi = lo + 1; end
        for i = 1:2
            if isempty(cur(i).R), continue; end
            rgb = makeRGB(cur(i).R, cur(i).G, lo, hi, ddView.Value);
            set(hImg(i), 'CData', rgb, 'XData', [1 size(rgb, 2)], 'YData', [1 size(rgb, 1)]);
        end
    end

    function fitView(i)
        if isempty(cur(i).R), return; end
        [h, w] = size(cur(i).R);
        ax(i).XLim = [0.5 w + 0.5];
        ax(i).YLim = [0.5 h + 0.5];
    end

    function fitAll()
        fitView(1);
        fitView(2);
    end

    function setZoomMode(tf)
        for i = 1:2
            try
                if tf
                    ax(i).Interactions = [zoomInteraction panInteraction];
                else
                    ax(i).Interactions = [];
                end
            catch
                % older releases without axes Interactions: ignore
            end
        end
        if tf
            for i = 1:2
                if ~isempty(lblInfo(i)) && ~isempty(cur(i).R)
                    lblInfo(i).Text = 'Zoom / pan is on: scroll or drag the image. Turn it off to place points.';
                end
            end
        else
            updateHints();
        end
    end

    function onProj()
        updateCur(1);
        updateCur(2);
        refreshImages();
        updateProfiles();
    end

    function onZ(i, v)
        v = round(v);
        zsel(i) = v;
        if cbLink.Value
            j = 3 - i;
            if ~isempty(stk(j).R)
                zsel(j) = min(max(v, 1), size(stk(j).R, 3));
                sld(j).Value = min(max(zsel(j), 1), sld(j).Limits(2));
                updateCur(j);
            end
        end
        updateCur(i);
        refreshImages();
        updateProfiles();
    end

    function onImageClick(i, evt)
        if isempty(cur(i).R), return; end
        pt = [];
        try, pt = evt.IntersectionPoint(1:2); catch, end %#ok<NOCOM>
        if isempty(pt) || any(~isfinite(pt))
            cp = ax(i).CurrentPoint;
            pt = cp(1, 1:2);
        end
        [h, w] = size(cur(i).R);
        pt = [min(max(pt(1), 1), w), min(max(pt(2), 1), h)];
        P = pts{i};
        if size(P, 1) < 2
            P(end + 1, :) = pt;
        else
            d = sum((P - pt) .^ 2, 2);
            [~, kk] = min(d);
            P(kk, :) = pt;
        end
        pts{i} = P;
        update();
    end

    function clearLines()
        pts = {zeros(0, 2), zeros(0, 2)};
        update();
    end

    function update()
        drawOverlays();
        updateProfiles();
        updateHints();
    end

    function drawOverlays()
        hw = max(1, round(spBand.Value)) / 2;
        for i = 1:2
            P = pts{i};
            if isempty(P)
                set(hPt(i), 'XData', NaN, 'YData', NaN);
            else
                set(hPt(i), 'XData', P(:, 1), 'YData', P(:, 2));
            end
            for j = 1:2
                if j <= size(P, 1)
                    set(hTxt(i, j), 'Position', [P(j, 1) P(j, 2) 0], 'Visible', 'on');
                else
                    set(hTxt(i, j), 'Visible', 'off');
                end
            end
            g = geom(P);
            if isempty(g)
                set(hLine(i), 'XData', NaN, 'YData', NaN);
                set(hBand(i), 'XData', NaN, 'YData', NaN);
            else
                c = [g.a + g.n * hw; g.b + g.n * hw; g.b - g.n * hw; g.a - g.n * hw];
                set(hBand(i), 'XData', c(:, 1), 'YData', c(:, 2));
                set(hLine(i), 'XData', [g.a(1) g.b(1)], 'YData', [g.a(2) g.b(2)]);
            end
        end
    end

    function updateHints()
        for i = 1:2
            if isempty(cur(i).R)
                lblInfo(i).Text = 'No image loaded. Use the Load button.';
            else
                switch size(pts{i}, 1)
                    case 0
                        lblInfo(i).Text = 'Click the image to place point 1.';
                    case 1
                        lblInfo(i).Text = 'Click to place point 2.';
                    otherwise
                        lblInfo(i).Text = 'Click to move the nearest point. Zoom / pan lets you zoom in first.';
                end
            end
        end
    end

    function updateProfiles()
        recomputeProfiles();
        plotProfiles();
        updateStats();
    end

    function recomputeProfiles()
        Wb = max(1, round(spBand.Value));
        useRed = strcmp(ddChan.Value, 'Red');
        aggMax = strcmp(ddAgg.Value, 'Max');
        win = max(1, round(spSmooth.Value));
        gs = cell(1, 2);
        Ls = nan(1, 2);
        for i = 1:2
            gs{i} = geom(pts{i});
            if ~isempty(gs{i}) && ~isempty(cur(i).R)
                Ls(i) = gs{i}.L;
            else
                gs{i} = [];
            end
        end
        prof = struct('v', {[], []}, 'sm', {[], []}, 'L', {NaN, NaN});
        profX = [];
        if all(isnan(Ls)), return; end
        M = min(4000, max(2, round(max(Ls(~isnan(Ls))))));
        profX = linspace(0, 100, M);
        for i = 1:2
            if isempty(gs{i}), continue; end
            if useRed, I = cur(i).R; else, I = cur(i).G; end
            v = sampleBand(I, gs{i}, M, Wb, aggMax);
            prof(i).v = v;
            prof(i).L = gs{i}.L;
            if win > 1
                prof(i).sm = movmean(v, win, 'omitnan');
            else
                prof(i).sm = v;
            end
        end
    end

    function plotProfiles()
        vmax = 0;
        for i = 1:2
            if isempty(prof(i).sm)
                set(hP(i), 'XData', NaN, 'YData', NaN);
            else
                set(hP(i), 'XData', profX, 'YData', prof(i).sm);
                s = prof(i).sm(isfinite(prof(i).sm));
                if ~isempty(s), vmax = max(vmax, max(s)); end
            end
        end
        if vmax > 0
            axP.YLim = [0 vmax * 1.08];
        else
            axP.YLimMode = 'auto';
        end
        axP.XLim = [0 100];

        if cbDiff.Value && ~isempty(prof(1).sm) && ~isempty(prof(2).sm)
            x = profX;
            d = prof(2).sm - prof(1).sm;
            ok = isfinite(d);
            dd = d;
            dd(~ok) = 0;
            dp = max(dd, 0);
            dn = min(dd, 0);
            set(hDpos, 'XData', [x fliplr(x)], 'YData', [dp zeros(size(dp))]);
            set(hDneg, 'XData', [x fliplr(x)], 'YData', [dn zeros(size(dn))]);
            set(hDline, 'XData', x, 'YData', d);
            m = max(abs(d(ok)));
            if isempty(m) || m == 0, m = 1; end
            axD.YLim = [-m m] * 1.1;
            axD.XLim = [0 100];
        else
            set(hDpos, 'XData', NaN, 'YData', NaN);
            set(hDneg, 'XData', NaN, 'YData', NaN);
            set(hDline, 'XData', NaN, 'YData', NaN);
        end
    end

    function updateStats()
        rows = cell(3, 6);
        st = cell(1, 2);
        for i = 1:2
            if isempty(prof(i).v)
                rows(i, :) = {nm{i}, '-', '-', '-', '-', '-'};
                continue
            end
            v = prof(i).v;
            mu = mean(v(isfinite(v)));
            [pk, ix] = max(v);
            P = pts{i};
            rows(i, :) = {nm{i}, ...
                sprintf('(%.0f, %.0f) to (%.0f, %.0f)', P(1, 1), P(1, 2), P(2, 1), P(2, 2)), ...
                sprintf('%.0f', prof(i).L), sprintf('%.1f', mu), ...
                sprintf('%.1f (at %.0f%%)', pk, profX(ix)), sprintf('%.0f', mu * prof(i).L)};
            st{i} = struct('mu', mu, 'pk', pk, 'area', mu * prof(i).L, 'L', prof(i).L);
        end
        if ~isempty(st{1}) && ~isempty(st{2})
            a = st{1};
            b = st{2};
            if a.mu > 0, rr = sprintf('  (x%.2f)', b.mu / a.mu); else, rr = ''; end
            if a.area > 0, ra = sprintf('  (x%.2f)', b.area / a.area); else, ra = ''; end
            rows(3, :) = {[nm{2} ' - ' nm{1}], '', sprintf('%+.0f', b.L - a.L), ...
                [sprintf('%+.1f', b.mu - a.mu) rr], sprintf('%+.1f', b.pk - a.pk), ...
                [sprintf('%+.0f', b.area - a.area) ra]};
        else
            rows(3, :) = {'', '', '', '', '', ''};
        end
        tbl.Data = rows;
    end

    function exportProfiles()
        if isempty(profX) || (isempty(prof(1).v) && isempty(prof(2).v))
            uialert(fig, 'Place a line on at least one image first.', 'Nothing to export');
            return
        end
        [f, p] = uiputfile('line_profile.csv', 'Save profile as CSV');
        if isequal(f, 0), return; end
        n = numel(profX);
        a = nan(n, 1);
        b = nan(n, 1);
        if ~isempty(prof(1).v), a = prof(1).v(:); end
        if ~isempty(prof(2).v), b = prof(2).v(:); end
        n1 = matlab.lang.makeValidName(nm{1});
        n2 = matlab.lang.makeValidName(nm{2});
        if strcmp(n1, n2), n1 = [n1 '_1']; n2 = [n2 '_2']; end
        T = table(profX(:), a, b, b - a, 'VariableNames', {'position_pct', n1, n2, 'difference'});
        writetable(T, fullfile(p, f));
        out = struct('table', T, 'points', {pts}, 'bandWidthPx', round(spBand.Value), ...
            'channel', ddChan.Value, 'combine', ddAgg.Value, 'zPlane', zsel, ...
            'base', {{stk(1).base, stk(2).base}});
        assignin('base', 'lineProfile', out);
        uialert(fig, sprintf('Saved %s\nAlso copied to the workspace as the variable lineProfile.', ...
            fullfile(p, f)), 'Exported', 'Icon', 'success');
    end

    function h = place(h, r, c)
        h.Layout.Row = r;
        h.Layout.Column = c;
    end

end


%% ===================== local helpers =====================

function rgb = makeRGB(R, G, lo, hi, viewMode)
s = 1 / max(hi - lo, eps);
r = min(max((R - lo) * s, 0), 1);
g = min(max((G - lo) * s, 0), 1);
switch viewMode
    case 'Red only'
        g(:) = 0;
    case 'Green only'
        r(:) = 0;
end
rgb = cat(3, r, g, zeros(size(r)));
end

function g = geom(P)
g = [];
if size(P, 1) < 2, return; end
a = P(1, :);
b = P(2, :);
d = b - a;
L = hypot(d(1), d(2));
if L < 1, return; end
u = d / L;
g = struct('a', a, 'b', b, 'd', d, 'L', L, 'u', u, 'n', [-u(2) u(1)]);
end

function v = sampleBand(I, g, M, Wb, aggMax)
% average (or max) of Wb pixels across the line at each of M positions along it
t = linspace(0, 1, M);
cx = g.a(1) + g.d(1) * t;
cy = g.a(2) + g.d(2) * t;
off = ((0:Wb - 1) - (Wb - 1) / 2).';
X = repmat(cx, Wb, 1) + g.n(1) * repmat(off, 1, M);
Y = repmat(cy, Wb, 1) + g.n(2) * repmat(off, 1, M);
V = interp2(I, X, Y, 'linear', NaN);
if aggMax
    v = max(V, [], 1);
else
    v = mean(V, 1, 'omitnan');
end
end
