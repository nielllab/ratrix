% TEST_SPRINGGRIDLAYOUT
%
%   A more complex example utilizing nested layouts and minimum
%   and maximum lengths for elements. 
%
% Copyright Brad Phelan 2005 <a href="matlab:web http://xtargets.com -browser">XTargets</a>
% You are free to modify or enhance this script as long as you follow the license guidelines.
% See the <a href="matlab: edit(fullfile(xtargets_hglayouts_root, 'license.txt'))">license file</a> for more information.
%
%
%
function test_springgridlayout
    f = figure('units','pixels','position',[10 10 7*80 500]);
    
    % Column 1 is fixed at 100 pixels.
    % All other columns are super stretchy around 100 pixels.
    col_ks = [ 0  0  0  0  0  0  0  ];
    col_ds = [ 200 80 80 80 80 80 80  ;
               40 80 0 80 0 80 0 ;
               300  80 80 80 80 80 inf];

    % Row 1 super stretchy around 100 pixels
    % All other rows are fixed at other pixel heights
    row_ks = [ 0   0   0  0   ];
    row_ds = [ 100 100 100 100 ;
               100 100 100 80  ;
               200 200 inf 150 ];
    
    % Initialize the layout
    layout = xtargets_springgridlayout(f, row_ks, row_ds, col_ks, col_ds);

    % Get a constraint structure.
    constraint = layout.create_constraint();

    for row = 2:4
        for col = 2:7
            constraint.col = col;
            constraint.row = row;
            h = uicontrol('string', sprintf('[r%d,c%d]',row,col), 'units', 'pixels');
            layout.add(h, constraint);
        end
    end

    % Create a control than spans 5 rows in the left column
    constraint.row = 1;
    constraint.col = 1;
    constraint.colspan = 1;
    constraint.rowspan = 5;
    uic = uicontainer('units','pixels');
    % Insert the test_borderlayout component from
    % one of the test scripts
    test_borderlayout(uic);
    layout.add(uic, constraint);
    
    % Create a control that sits at the top centre of the area
    % from [1 2] to [1 4]. The control does not fill the cell
    % but is aligned to the top centre of the cell.
    constraint.row = 1;
    constraint.col = 2;
    constraint.colspan = 3;
    constraint.rowspan = 1;
    constraint.padding = [5 5 5 5];
    constraint.fillx = false;
    constraint.alignx = 'centre';
    constraint.filly = false;
    constraint.aligny = 'top';
    layout.add(uicontrol('string','top','units','pixels'), constraint);
    
end
