% TEST_BORDERLAYOUT
%
% A simple example of how to use the xtargets_borderlayout. Run
% this script and then compare the GUI to the script to see
% how it all works.
%
% Shows how to use the units of inches
%
% Copyright Brad Phelan 2005 <a href="matlab:web http://xtargets.com -browser">XTargets</a>
% You are free to modify or enhance this script as long as you follow the license guidelines.
% See the <a href="matlab: edit(fullfile(xtargets_hglayouts_root, 'license.txt'))">license file</a> for more information.
%
%
% 
function test_borderlayout(f)
    if nargin ~= 1
        f = figure('units','inches','position',[0 0 3 3]);
        units = 'inches';
    else
        units = 'pixels';
    end
    
    layout = xtargets_borderlayout(f);

    layout.add(uicontrol('units',units,'string','north'),'north');
    layout.add(uicontrol('units',units,'string','south'),'south');
    layout.add(uicontrol('units',units,'string','east'),'east');
    layout.add(uicontrol('units',units,'string','west'),'west');
    layout.add(uicontrol('units',units,'string','centre'),'centre');


end
