function [imagelist] =PR_ImageSet1;  
% PR 090309
%
% same prefix and number, where lower number
% defines which is target.
% defines image sets for each training step
% imagelist.ts3 contains training step 3 images etc
% where rats are randomly assigned to target, there are A and B versions
% first filename in list is target, other(s) is(are) distractor(s)

% contains nike and blank, nike is target
imagelist.level1 ={ { {'Nike' 'blank'} 1.0} };

%  contains nike and shuttle, nike is target
imagelist.level2 ={ { {'Nike' 'Shuttle'} 1.0} };

% THIS STEP MIGHT BE IMPOSSIBLE??
%  contains nike and shuttle, nike is target; invariant to correct or mirror images!!
imagelist.level3 ={ ...
    { {'Nike' 'Shuttle' 'ShuttleMirror'} 2} ... % slight excess of familiar case
    { {'NikeMirror' 'Shuttle' 'ShuttleMirror'} 1} ... % but enough mirror images to count
    };

% THIS STEP HARD FOR A DIFFERENT REASON (more distrators)
%  contains nike (target) and either discobolus or shuttle
%(distractors).with mirror images
imagelist.level4 ={ ...
    { {'Nike' 'Shuttle' 'ShuttleMirror' 'Discobolus' 'DiscobolusMirror'} 1} ...
    { {'NikeMirror' 'Shuttle' 'ShuttleMirror' 'Discobolus' 'DiscobolusMirror'} 1} ...
    };
% but if failed level3, then go instead to this: NO mirror image of target required.
imagelist.level4easy ={{ {'Nike' 'Shuttle' 'ShuttleMirror' 'Discobolus' 'DiscobolusMirror'} 1}};

