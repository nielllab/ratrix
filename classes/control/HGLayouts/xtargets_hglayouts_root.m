% XTARGETS_HGLAYOUTS_ROOT
%   Returns the root directory

% copyright Brad Phelan 2005

% Copyright Brad Phelan 2005 <a href="matlab:web http://xtargets.com -browser">XTargets</a>
% You are free to modify or enhance this script as long as you follow the license guidelines.
% See the <a href="matlab: edit(fullfile(xtargets_hglayouts_root, 'license.txt'))">license file</a> for more information.

function dir = xtargets_hglayouts_root
    dir = fileparts(mfilename('fullpath'));
end
