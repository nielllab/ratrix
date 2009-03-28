function setupEnvironment

clear classes
clear java
clear mex
close all
clc
format long g
format compact

lasterror('reset')
lastwarn('')

warning('off','MATLAB:dispatcher:nameConflict')
addpath(RemoveSVNPaths(genpath(getRatrixPath)));
warning('on','MATLAB:dispatcher:nameConflict')

intwarning('on');
%enabling this because it's easy for users to unknowingly overflow ints in their setProtocols
%consider turning off MATLAB:intMathOverflow before running timesensitive stuff like runRealTimeLoop because it slows down all int math
%http://www.mathworks.com/access/helpdesk/help/techdoc/ref/intwarning.html
%but i don't think we actually do any int math in runRealTimeLoop, so let's leave it on for now and see

clearJavaComponents();
closeAllSerials
if IsWin
    daqreset
end

setupDBPaths();
%would like to have these taken care of in setupEnvironment(), but some java problem seems to conflict with making the rnet (addJavaComponents() does update the path, but the import fails to make the class def's visible)
%<i think there used to be references to addJavaComponents here?>
%ListenChar(2);
%FlushEvents('keyDown');
