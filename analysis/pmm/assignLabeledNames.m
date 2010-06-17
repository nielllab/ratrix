function [labeledNames markerSymbol]=assignLabeledNames(subjects)
% in order to considerly rename subject IDs for a paper specific labeled ID

%sorted for amound of data curently
pairing={'138','r1','o';
    '139','r2','s'; % 138 and 139 switched before publication 12/13/09, (convention changes away from most trials in first position)
    '234','r3','d';
    '233','r4','v';
    '230','r5','^';
    '227','r6','d'; % p?
    '228','r7','s'; % h?
     ... only used for more testing and supplimental, not for main figs
    '231','r8','.';
    ... only used for short durations, not main figs
    '232','r9','.';
    '237','r10','.';
    '229','r11','.';
    ... don't remember needing this.. maybe for sup?
    '277','r12','.'};
   
for i=1:length(subjects)
    which=strcmp(subjects{i},pairing); % as logicals
    if sum(which(:))==1
        ind=find(which(:,1));           % find the ind
        labeledNames{i}=pairing{ind,2}; % get the labeled name
        markerSymbol{i}=pairing{ind,3}; % get the symbol
    elseif  sum(which(:))==0
       labeledNames{i}='**'; % unknown or shuffle name
       markerSymbol{i}='.';  % unknown or shuffle symbol
    elseif sum(which(:))>1
        subjects{i}
        error('duplicate subjects')
    end
end