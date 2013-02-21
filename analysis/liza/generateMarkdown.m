% generates 'markdown' formatted file that can be uploaded to blog using BlogLiterately
% 'markdown' is a nicer-formatted shorthand for html
% 'BlogLiterately' is a haskell program that converts markdown to html and knows how to talk to blog engines
% to use it, install the haskell platform (http://hackage.haskell.org/platform/)
% then, at command prompt, 'cabal install BlogLiterately'

function generateMarkdown(upload)
dbstop if error

if ~exist('upload','var') || isempty(upload)
    upload = true;
end

out = 'C:\Users\nlab\Desktop\currentBehavior.md';

outh = fopen(out,'wt');
if outh<=2
    outh
    error('couldn''t fopen')
end
fprintf(outh,intercolate(md3,'\n'));
outh = fclose(outh);
if outh~=0
    outh
    error('couldn''t fclose')
end

if upload
    server = inputEF('server'                     ,'reichardt.uoregon.edu');
    id     = inputEF('id (new or 784 for BLTest)' ,'784');
    login  = inputEF('login'                      ,'eflister');
    pw     = inputEF('password');
    
    cmd = ['BlogLiterately --blog http://' server '/blog/xmlrpc.php --user ' login ' --password ' pw ' --publish --page'];
    
    switch id
        case 'new'
            title = inputEF('title');
        case '784'
            title = 'BLTest';
            cmd = [cmd ' --postid ' id];
            
        otherwise
            error('bad id')
    end
    cmd = [cmd ' --title "' title '" ' out];
    
    [status result] = system(cmd);
    if status~=0
        status
        warning('you may need to install haskell and/or BlogLiterately')
    end
    result
end
end

function out = inputEF(s,d)
if ~exist('d','var') || isempty(d)
    d2 = '';
else
    d2 = [' [' d ']'];
end

out = input([s d2 '\n'],'s');

if isempty(out)
    out = d;
end
end

function out = imgLink(sub,which,comment)
if ~exist('which','var') || isempty(which)
    which = {''};
end

if ~exist('comment','var') || isempty(comment)
    comment = '';
else
    comment = [' (' comment ')'];
end

root = 'http://reichardt.uoregon.edu/figures/';

out = cellfun(@f,which,'UniformOutput',false);

    function this = f(w)
        switch w
            case {'orientations','pixPerCyc','amp'}
                w = ['.' w '.psycho'];
            otherwise
                %pass
        end
        this = [root sub '/latest' w '.png'];
        this = ['[![' sub '](' this ')](' this ')'];
    end
out = ['- ' sub comment '\n' intercolate(out,'\n')];
end

function out = intercolate(c,i)
out = cell2mat(cellfun(@(x)[x i],{c{:}},'UniformOutput',false));
end

function out = md2
out = {
    '- spatial freq'
    '    - mtrix1'
   ['        ' imgLink('c1ln',{'','orientations','pixPerCyc'},'0.16 cpd')]
   ['        ' imgLink('c1lt',{'','orientations','pixPerCyc'},'0.08 cpd')]
   ['        ' imgLink('c2lt',{'','orientations','pixPerCyc'},'0.16 cpd')]
   ['        ' imgLink('c3ln',{'','orientations','pixPerCyc'},'0.08 cpd')]
    '    - mtrix2'
   ['        ' imgLink('c1rn',{'','orientations','pixPerCyc'},'0.16 cpd')]
   ['        ' imgLink('c1rt',{'','orientations','pixPerCyc'},'0.08 cpd')]
   ['        ' imgLink('c2rn',{'','orientations','pixPerCyc'},'0.16 cpd')]
   ['        ' imgLink('c2rt',{'','orientations','pixPerCyc'},'0.08 cpd')]
    '- orientation'
    '    - mtrix3 - abstract'
   ['        ' imgLink('j10rt',{},'small slow')]
   ['        ' imgLink('j6rt' ,{},'large fast')]
   ['        ' imgLink('j7rt' ,{},'small fast')]
   ['        ' imgLink('j8rt' ,{},'large slow')]
    '    - mtrix4 - tilt'
   ['        ' imgLink('j10ln',{'','orientations','pixPerCyc'})]
   ['        ' imgLink('j10lt',{'','orientations','pixPerCyc'})]
   ['        ' imgLink('j8ln' ,{'','orientations','pixPerCyc'})]
   ['        ' imgLink('j8lt' ,{'','orientations','pixPerCyc'})]   
    '- audio intensity'
    '    - mtrix1'
   ['        ' imgLink('3499',{'','amp'})]
   ['        ' imgLink('3513',{'','amp'})]
    '    - mtrix2'
   ['        ' imgLink('3350',{'','amp'})]
    '    - mtrix3'
   ['        ' imgLink('3500',{'','amp'})]
   ['        ' imgLink('3515',{'','amp'})]
    '    - mtrix4'
   ['        ' imgLink('3516',{'','amp'})]
    '- ball dms'
    '    - mtrix5'
   ['        ' imgLink('ly02')]
   ['        ' imgLink('ly09')]
    '    - jarmusch'
   ['        ' imgLink('ly04')]
   ['        ' imgLink('ly08')]   
    '- ball grating'   
    '    - mtrix6'
   ['        ' imgLink('ly01')]
    '    - jarmusch'
   ['        ' imgLink('ly03')]
    };
end

function out = md
out = {    
    '- orientation'
    '    - mtrix2'
   ['        ' imgLink('c4rn')]
   ['        ' imgLink('c4rt')]
   ['        ' imgLink('c5rn')]
   ['        ' imgLink('c5rt')]
   
    '- audio intensity'
    '    - mtrix2'
   ['        ' imgLink('3691')]
    '    - mtrix3'
   ['        ' imgLink('3694')]  
   
    '- ball dms'
    '    - mtrix5'
   ['        ' imgLink('ly14')]
   ['        ' imgLink('ly11')]
    '    - jarmusch'
   ['        ' imgLink('ly12')]  
    '    - mtrix6'
   ['        ' imgLink('ly10')]
   ['        ' imgLink('ly13')]   
   ['        ' imgLink('ly15')]      
   
    '- grating'
%     '    - mtrix5'
%    ['        ' imgLink('jbw03')]  
    '    - mtrix6'
%    ['        ' imgLink('jbw01')]   
   ['        ' imgLink('jbw02')]   
   ['        ' imgLink('jbw04')]     
%    ['        ' imgLink('wg2'  )]    
%     '    - lee'
%    ['        ' imgLink('gcam13ln')]   
%    ['        ' imgLink('gcam13tt')]   

    '- orient'
    '    - mtrix5'
   ['        ' imgLink('gcam13ln')]
   ['        ' imgLink('jbw03')]
    '    - jarmusch'
   ['        ' imgLink('gcam13tt')]  
    '    - mtrix6'
   ['        ' imgLink('wg2')]
   ['        ' imgLink('jbw01')]   

    '- whatwhere'
    '    - mtrix5'
   ['        ' imgLink('gcam20tt')]
   ['        ' imgLink('gcam21rt')]
    '    - jarmusch'
   ['        ' imgLink('gcam17tt')]  
   ['        ' imgLink('wg4lt')]  
   '    - mtrix6'
   ['        ' imgLink('gcam17rn')]
   ['        ' imgLink('wg4rt')]      
   
   };
end

function out = md3
out = {
    '- orient'
    '    - mtrix5'
   ['        ' imgLink('gcam13ln')]
   ['        ' imgLink('jbw03')]
    '    - jarmusch'
   ['        ' imgLink('gcam13tt')]  
    '    - mtrix6'
   ['        ' imgLink('wg2')]
   ['        ' imgLink('jbw01')]   

    '- whatwhere'
    '    - mtrix5'
   ['        ' imgLink('gcam20tt')]
   ['        ' imgLink('gcam21rt')]
    '    - jarmusch'
   ['        ' imgLink('gcam17tt')]  
   '    - mtrix6'
   ['        ' imgLink('gcam17rn')]
   ['        ' imgLink('wg4rt')]      
   
   };
end