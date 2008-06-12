% BORDERLAYOUT classic borderlayout engine for handle graphics
%
%   layout = xtargets_borderlayout(container)
%
% A borderlayout can be added to any figure, uipanel or uicontainer
% object in the handle graphics hierarchy. It modifies the resizefcn
% callback on the container so you should not modify this property of
% the container yourself.
%
% Arguments
%     container   -  figure, uipanel, uicontainer objects
%
% Returns
%     layout      -  structure with the following field(s)
%
%                    * add -  function_handle to be called as
%              
%                    add( control, location ) - where
%
%                    control  -  any hg control
%                    location -  'north'
%                                'south'
%                                'east'
%                                'west'
%                                'centre'
%      
%
% Usage.
%
%   
%    f = figure('units','pixels','position',[10 10 500 500]);
%    
%    layout = xtargets_borderlayout(f);
%
%    layout.add(uicontrol('units','pixels','string','north'),'north');
%    layout.add(uicontrol('units','pixels','string','south'),'south');
%    layout.add(uicontrol('units','pixels','string','east'),'east');
%    layout.add(uicontrol('units','pixels','string','west'),'west');
%    layout.add(uicontrol('units','pixels','string','centre'),'centre');
%
% Notes
%    To use this layout all components need to have the same units set. This
%    layout does not work with 'normalized' units.
%
% See also XTARGETS_SPRINGGRIDLAYOUT, TEST_BORDERLAYOUT
%
% Copyright Brad Phelan 2005 <a href="matlab:web http://xtargets.com -browser">XTargets</a>
% You are free to modify or enhance this script as long as you follow the license guidelines.
% See the <a href="matlab: edit(fullfile(xtargets_hglayouts_root, 'license.txt'))">license file</a> for more information.
%
function layout = xtargets_borderlayout(panel)
    components.north = [];
    components.south = [];
    components.east = [];
    components.west = [];
    components.centre = [];

    row_ks = [1 0 1];
    row_ds = [1 1 1];
    col_ks = [1 0 1];
    col_ds = [1 1 1];

    spring_layout = xtargets_springgridlayout(panel, row_ks, row_ds, col_ks, col_ds);

    % Create layout object
    layout.add = @add;

    function calc_kds
        east_k  = 1;
        west_k  = 1;
        north_k = 1;
        south_k = 1;
        centre_k = 0;

        row_ks = [ north_k centre_k south_k ];
        col_ks = [ west_k centre_k east_k ];

        row_ds = [0 0 0];
        col_ds = [0 0 0];

        if ~isempty(components.north)
            position = get(components.north, 'position');
            height = position(4);
            row_ds(1) = height;
        else
            row_ds(1) = 0;
        end

        if ~isempty(components.south)
            position = get(components.south, 'position');
            height = position(4);
            row_ds(3) = height;
        else
            row_ds(3) = 0;
        end

        if ~isempty(components.east)
            position = get(components.east, 'position');
            width = position(3);
            col_ds(1) = width ;
        else
            col_ds(1) = 0;
        end

        if ~isempty(components.west)
            position = get(components.west, 'position');
            width = position(3);
            col_ds(3) = width ;
        else
            col_ds(3) = 0;
        end

        spring_layout.set_cols(col_ks, col_ds);
        spring_layout.set_rows(row_ks, row_ds);

    end


    function add(component, location)
        location = lower(location);
        switch lower(location)
        case { 'north'  'south'  'east'  'west' 'centre' }
            delete(components.(location)); 
            components.(location) = component;
        otherwise
            error(['Bad location: ' location]);
        end

        constraint = spring_layout.create_constraint;
        switch location
        case 'north'
            constraint = spring_layout.create_constraint([1 1 1 3]);
            spring_layout.add(component, constraint);
        case 'south'
            constraint = spring_layout.create_constraint([3 1 1 3]);
            spring_layout.add(component, constraint);
        case 'east'
            constraint = spring_layout.create_constraint([2 1 1 1]);
            spring_layout.add(component, constraint);
        case 'west'
            constraint = spring_layout.create_constraint([2 3 1 1]);
            spring_layout.add(component, constraint);
        case 'centre'
            constraint = spring_layout.create_constraint([2 2 1 1]);
            spring_layout.add(component, constraint);
        end

        % Update the spring_layout
        calc_kds;

    end
end
