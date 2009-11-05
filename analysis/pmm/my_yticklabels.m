function ht = my_yticklabels(varargin)

%MY_YTICKLABELS replaces YTickLabels with "normal" texts
%   accepting multiline texts and TEX interpreting
%   and shrinks the axis to fit the texts in the window
%
%    ht = my_yticklabels(Ha, ytickpos, ytickstring)
% or
%    ht = my_yticklabels(ytickpos, ytickstring)
%
%  in:    ytickpos     YTick positions [N*1]
%        ytickstring   Strings to use as labels {N*1} cell of cells
%
% Examples:
% plot(randn(20,1))
% ytl = {{'one';'two';'three'} '\alpha' {'\beta';'\gamma'}};
% h = my_yticklabels(gca,[-1 0 1],ytl);
% % vertical
% h = my_yticklabels([-1 0 1],ytl, ...
%     'Rotation',-90, ...
%     'VerticalAlignment','middle', ...
%     'HorizontalAlignment','center');

% Pekka Kumpulainen 5.3.2008

% Copyright (c) 2009, Pekka Kumpulainen
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

textopts = {};
if length(varargin{1})==1 && ...
        ishandle(varargin{1}) && ...
        strcmpi(get(varargin{1},'Type'),'axes');
    Ha = varargin{1};
    ytickpos = varargin{2};
    ytickstring = varargin{3};
    if nargin > 3
        textopts = varargin(4:end);
    end
else
    Ha = gca;
    %Hfig = get(Ha,'Parent');
    ytickpos = varargin{1};
    ytickstring = varargin{2};
    if nargin > 2
        textopts = varargin(3:end);
    end
end

set(Ha,'YTick',ytickpos, 'YTickLabel','')
h_olds = findobj(Ha, 'Tag', 'MUYTL');
if ~isempty(h_olds)
    delete(h_olds)
end

%% Make XTickLabels 
NTick = length(ytickpos);
Xbot = min(get(gca,'XLim'));
ht = zeros(NTick,1);
for ii = 1:NTick
    ht(ii) = text('String',ytickstring{ii}, ...
        'Units','data', ...
        'VerticalAlignment', 'middle', ...
        'HorizontalAlignment', 'center', ...
        'Position',[Xbot ytickpos(ii)], ...
        'Tag','MUYTL');
end
if ~isempty(textopts)
    set(ht,textopts{:})
end

%% shift texts left to fit & squeeze axis if needed

set(Ha,'Units','pixels')
Axpos = get(Ha,'Position');
% set(Hfig,'Units','pixels')
% Figpos = get(Hfig,'Position');

set(ht,'Units','pixels')
TickPos = zeros(NTick,3);
TickExt = zeros(NTick,4);
for ii = 1:NTick
    TickPos(ii,:) = get(ht(ii),'Position');
    tmpext = get(ht(ii),'Extent');
    set(ht(ii),'Position',[TickPos(ii,1)-tmpext(3)/2-5 TickPos(ii,2:end)])
    TickExt(ii,:) = get(ht(ii),'Extent');
end

needmove = -(Axpos(1) + min(TickExt(:,1)));

if needmove>0;
    Axpos(1) = Axpos(1)+needmove+2;
    Axpos(3) = Axpos(3)-needmove+2;
    set(Ha,'Position',Axpos);
end

set(Ha,'Units','normalized')
set(ht,'Units','normalized')
