% XTARGETS_SPRINGGRIDLAYOUT gridbag like layout component for handle graphics
%
%     layout = xtargets_springgridlayout( panel, s_rows, d_rows, s_cols, d_cols )
% 
% Creates a spring grid layout for the panel or figure
% components. A spring grid layout creates a mathematical
% relationship between columns and rows based on the idea
% of springs. Each cell dimension is represented by a spring.
%
% A spring has the following properties.
%   S       -   spring stiffness 0 <= s <= 1
%   D       -   rest length
%   Dmin    -   minimum length of the spring 
%   Dmax    -   maximum length of the spring
%
% By joining a set of springs up in series you get columns or rows that
% change shape according to thier spring properties.
%
% For example a column with a stiffness of 1 will always maintain
% the width of its rest position. A column with stiffness of 0 will
% always expand to fill as much space as possible.
%
% Arguments
%     panel     -   figure, uipanel or uicontainer handle
%     s_rows    -   Vector of spring stiffness for rows
%     d_rows    -   Matrix of spring lengths for rows.  
%                      row1    -   default length
%                      row2    -   minimum length
%                      row3    -   maximum length
%                   It is not necessary to specify the min and max 
%                   length rows. If left out then they default to
%                   0 and Inf respectively.
%     s_cols    -   As for s_rows
%     d_cols    -   As for s_cols
%
% Notes
%   If it is not possible to satisfy the constraints then the gui
%   algorithm degrades the constraints gracefully. This means that
%   min and max length specifications are not necessarily honored
%   but are used as a guide. 
%
% Example
%
%    f = figure('units','pixels','position',[10 10 500 500]);
%    
%    % Column 1 is fixed at 100 pixels.
%    % All other columns are super stretchy around 100 pixels.
%    col_ks = [ 1  0   0   0  ];
%    col_ds = [ 100 100 100 100 ] ;
%
%    % Row 1 super stretchy around 100 pixels
%    % All other rows are fixed at other pixel heights
%    row_ks = [ 0   1   1  1   ];
%    row_ds = [ 100 100 20 100 ];
%    
%    % Initialize the layout
%    layout = xtargets_springgridlayout(f, row_ks, row_ds, col_ks, col_ds);
%
%    % Get a constraint structure.
%    constraint = layout.create_constraint();
%
%    for row = 2:4
%        for col = 2:4
%            constraint.col = col;
%            constraint.row = row;
%            h = uicontrol('string', sprintf('[r%d,c%d]',row,col), 'units', 'pixels');
%            layout.add(h, constraint);
%        end
%    end
%
%    % Create a control than spans 5 rows in the left column
%    constraint.row = 1;
%    constraint.col = 1;
%    constraint.colspan = 1;
%    constraint.rowspan = 5;
%    layout.add(uicontrol('string','left','units','pixels'), constraint);
%    
%    % Create a control that sits at the top centre of the area
%    % from [1 2] to [1 4]. The control does not fill the cell
%    % but is aligned to the top centre of the cell.
%    constraint.row = 1;
%    constraint.col = 2;
%    constraint.colspan = 3;
%    constraint.rowspan = 1;
%    constraint.padding = [5 5 5 5];
%    constraint.fillx = false;
%    constraint.alignx = 'centre';
%    constraint.filly = false;
%    constraint.aligny = 'top';
%    layout.add(uicontrol('string','top','units','pixels'), constraint);
%
%
% See also XTARGETS_BORDERLAYOUT, TEST_SPRINGLAYOUT, TEST_LARGESPRINGLAYOUT
%
% Copyright Brad Phelan 2005 <a href="matlab:web http://xtargets.com -browser">XTargets</a>
% You are free to modify or enhance this script as long as you follow the license guidelines.
% See the <a href="matlab: edit(fullfile(xtargets_hglayouts_root, 'license.txt'))">license file</a> for more information.

function layout = xtargets_springgridlayout( panel, s_rows, d_rows, s_cols, d_cols )


    set_rows(s_rows, d_rows);
    set_cols(s_cols, d_cols);


    % ROW_HEIGHTS
    %
    % Calculate the individual heights and width of each row
    % and column spring.
    %
    % Arguments
    %   height  -   The height of the container
    %
    % Returns
    %   heights -   Vector : the height of each row
    function heights = row_heights(height)
        heights = calc_sub_lengths(height, s_rows, d_rows);
    end

    % COL_WIDTHS
    %
    % Arguments
    %   width  -   The width of the container
    %
    % Returns
    %   widths -   Vector : the width of each column
    function widths = col_widths(width)
        widths = calc_sub_lengths(width, s_cols, d_cols);
    end

    panel = handle(panel);
    set(panel, 'resizefcn', @grid_resize);

    % Create the layout object to return
    layout.add = @add;
    layout.set_cols = @set_cols;
    layout.set_rows = @set_rows;
    layout.create_constraint = @create_constraint;

    % Create constraints vector
    constraints = [];

    function set_cols(s_cols_, d_cols_)
        s_cols = s_cols_;
        d_cols = d_cols_;
        if size(d_cols,1) == 1
            % No min or max sizes specified.
            % Augment the vector
            d_cols = [ d_cols; zeros(1,numel(d_cols)); inf(1, numel(d_cols)) ];
        end
    end 

    function set_rows(s_rows_, d_rows_)
        s_rows = s_rows_;
        d_rows = d_rows_;
        if size(d_rows,1) == 1
            % No min or max sizes specified.
            % Augment the vector
            d_rows = [ d_rows; zeros(1,numel(d_rows)); inf(1, numel(d_rows)) ];
        end
    end 


    function add( h, constraint)

        % Make sure the control is parented properly
        set(h,'parent',panel);

        % Create a new constraint
        constraint.handle = handle(h);

        % Add the constraint to the list of constraints.
        constraints = [ constraints constraint ];
    end

    function grid_resize(src, data)
        position = panel.position;
        dim = position(3:4);

        % Row and column heights
        rh = row_heights(dim(2));
        cw = col_widths(dim(1));

        % Row and column positions. Note that the lowest
        % pixel point is 1 not 0. Also our row counts start
        % from the top of the screen and count down but handle
        % graphics lowest valued vertical coordinate is at the
        % bottom of the screen thus all the fliplr stuff
        % for row_pos calculation.
        if strcmp(get(panel,'units'),'pixels')
            start_location = 1;
        else
            start_location = 0;
        end
        row_pos = fliplr(cumsum([start_location fliplr(rh(2:end))]));
        col_pos = cumsum([start_location cw(1:end-1)]);

        handles = [ constraints.handle ];
        positions = get(handles,'position'); 
        if ~iscell(positions)
            % Only one handle will return as a vector not
            % a cell of vectors
            positions = { positions };
        end
        for i = 1:length(constraints)
            c = constraints(i);
            position = positions{i};

            % Calculate the X position and
            % width of the cell the control
            % will live in.
            x_pos = col_pos(c.col);
            width = 0;
            for j = 0:(c.colspan-1)
                if j + c.col > length(cw)
                    break;
                end
                width = width + cw(c.col+j);
            end

            if ~c.fillx

                % Calculate the X alignment
                switch c.alignx
                case 'left'
                    x_pos = x_pos + c.padding(4);
                case 'right'
                    x_pos = x_pos + width - position(3) - c.padding(2);
                case 'centre'
                    x_pos = x_pos + width/2 - position(3)/2;
                end

                % The widget does not fill the width of the cell
                % and inherits the width of the uicontrol
                width = position(3);
            else
                x_pos = x_pos + c.padding(4);
                width = width - ( c.padding(2) + c.padding(4) );

            end

            % Calculate the Y position and
            % height of the cell the control will
            % live in
            y_pos = row_pos(c.row);
            height = 0;
            for j = 0:(c.rowspan-1)
                if j + c.row > length(rh)
                    break;
                end
                height = height + rh(c.row+j);
                if j > 0
                    y_pos = y_pos - rh(c.row+j);
                end
            end

            if ~c.filly

                % Calculate Y alignment
                switch c.aligny
                case 'top'
                    y_pos = y_pos + height - position(4) - c.padding(1); 
                case 'bottom'
                    % As default 
                    y_pos = y_pos + c.padding(3); 
                case 'centre'
                    y_pos = y_pos + height/2 - position(4)/2; 
                end

                % The widget does not fill the height of the cell
                % and inherits the height of the uicontrol
                height = position(4);
            else
                y_pos = y_pos + c.padding(3); 
                height = height - ( c.padding(1) + c.padding(3) );
            end

            % Define the final position
            position = [ x_pos y_pos width height  ];

            % Make sure we haven't shrunk the objects below 0
            position = max(0, position);


            % Set the position
            %handle = c.handle;
            %handle.position = position; 
            positions{i} = position;
        end
        set(handles, {'position'}, positions);

    end

end

% ------------------------------------------------
%           Non Nested Functions
% ------------------------------------------------



% K
%
% Return the overall spring constant given an array
% of spring stiffnesses

function k = K(s)
    if all(s == 1)
        k = inf;
    else
        k = 1 / (sum(1./stiffness(s)));
    end
end

% F
%
% Calculate the force across the array of elements
%
% Arguments
%   length      -   The total length of the elements
%   s           -   Stiffness vector
%   d           -   Element length vector
%
function f = F(length, s, d)
    f = K(s) * (length - sum(d));
end

% STIFFNESS
%
% Convert the stiffess parameters which lies
% between 0 and 1 into the spring constant k
function k = stiffness(k)
    for i = 1:length(k)
        if k(i) == 1
            k(i) = inf;
        else
            k(i) = 1 / ( 1 - k(i));
        end
    end
end

% CALC_SUB_LENGTHS
%
% For a given input length and S and D matrices find
% the lengths of each element
%
% Arguments
%   length      -   The total length of the elements
%   s           -   Stiffness vector
%   d_matrix    -   Three row matrix.
%                   row1    -   default lengths
%                   row2    -   min lengths
%                   row3    -   max lengths

function lengths = calc_sub_lengths(length, s, d_matrix)

    d = d_matrix(1,:);

    while 1
        lengths = F(length, s, d) ./ stiffness(s) + d;

        min_d = d_matrix(2,:);
        lts = find( lengths < min_d);
        d(lts) = min_d(lts);
        s(lts) = 1;

        max_d = d_matrix(3,:);
        gts = find( lengths > max_d);
        d(gts) = max_d(gts);
        s(gts) = 1;


        if all(s==1)
            % All the columns are too stiff to be solved so we
            % degrade the solution gracefully.
            s(:) = 0;
            if numel(lts) > numel(gts)
                % All the elements are shrunk to their min lengths.
                % Degrade gracefully by shrinking all components evenly
                % down to 0 from thier minimum lengths.
                d = min_d;
                while 1
                    % Iterate till no more elements are shrunk below
                    % zero.
                    lts = find( lengths < 0 );
                    d(lts) = 0;
                    s(lts) = 1;
                    lengths = F(length, s, d) ./ stiffness(s) + d;
                    if numel(lts) == 0
                        break;
                    end
                end
            else
                % All the elements are stretched beyond thier
                % maximum lengths
                d = max_d;
                lengths = F(length, s, d) ./ stiffness(s) + d;
            end
            break;
        end
        %  lengths = max(0, F(length, s, d) ./ stiffness(s) + d);
        %  break;

        if isempty(gts) && isempty(lts)
            break;
        end
    end

    if sum(lengths) ~= length
        %           error('Mismatch');
    end
end

% Default constraint structure
function c = create_constraint(position)

    c.row = 1;
    c.col = 1;
    c.rowspan = 1;
    c.colspan = 1;
    c.padding = [0 0 0 0];
    c.fillx = true;
    c.filly = true;
    c.alignx = 'centre'; % 'top' | 'bottom' | 'centre'
    c.aligny = 'centre'; % 'left' | 'right' | 'centre'

    if nargin == 1
        if isnumeric(position) && length(position) == 4
            c.row = position(1);
            c.col = position(2);
            c.rowspan = position(3);
            c.colspan = position(4);
        else
            error('Expect a 4 element vector for position');
        end
    end
end
