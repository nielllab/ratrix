function labeledNames=assignLabeledNames(subjects)
% in order to considerly rename subject IDs for a paper specific labeled ID

%sorted for amound of data curently
pairing={'139','r1';
    '138','r2';
    '234','r3';
    '233','r4';
    '230','r5';
    '227','r6';
    '228','r7';
    ... only used for short durations, not main figs
    '232','r8';
    '237','r9';
    '229','r10';
    ... only used for more testing and supplimental, not for main figs
    '277','r11'
    '231','r12'};
   
for i=1:length(subjects)
    which=strcmp(subjects{i},pairing); % as logicals
    if sum(which(:))==1
        ind=find(which(:,1));           % find the ind
        labeledNames{i}=pairing{ind,2}; % get the labeled name
    else
        subjects{i}
        error('missing or duplicate subjects')
    end
end