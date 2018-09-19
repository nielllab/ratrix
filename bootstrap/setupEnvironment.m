function setupEnvironment(lite)
if ~exist('lite','var') || isempty(lite)
    lite = false;
end

if ~lite
    close all
    clear java
    colordef black
    
    clear classes
    clear mex
end


clc
format long g
format compact

lasterror('reset')
lastwarn('')

warning('off','MATLAB:dispatcher:nameConflict')
addpath(fullfile(getRatrixPath,'classes','util','infrastructure')); %for deGitify
addpath(fullfile(getRatrixPath,'classes','util','parallelPort')); %for getPP

% [~, matlab64] = getPP;
matlab64=1;

if matlab64
    addpath(deGitify(genpath(getRatrixPath)));
else
    addpath(deGitify(RemoveSVNPaths(genpath(getRatrixPath))));
end
warning('on','MATLAB:dispatcher:nameConflict')

%intwarning('on'); $edf removed cuz 2011b eliminated intwarning
%enabling this because it's easy for users to unknowingly overflow ints in their setProtocols
%consider turning off MATLAB:intMathOverflow before running timesensitive stuff like runRealTimeLoop because it slows down all int math
%http://www.mathworks.com/access/helpdesk/help/techdoc/ref/intwarning.html
%but i don't think we actually do any int math in runRealTimeLoop, so let's leave it on for now and see

clearJavaComponents();
closeAllSerials
% if ispc
%     DaqReset
% end

setupDBPaths();
%would like to have these taken care of in setupEnvironment(), but some java problem seems to conflict with making the rnet (addJavaComponents() does update the path, but the import fails to make the class def's visible)
%<i think there used to be references to addJavaComponents here?>
%ListenChar(2);
%FlushEvents('keyDown');

fixSystemTime;
try
    removeLibusb;
end
