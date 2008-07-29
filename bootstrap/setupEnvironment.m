function setupEnvironment

clear classes
clear java
clear mex
close all
clc
format long g

lasterror('reset')
lastwarn('')

warning('off','MATLAB:dispatcher:nameConflict')
addpath(RemoveSVNPaths(genpath(getRatrixPath)));
warning('on','MATLAB:dispatcher:nameConflict')

clearJavaComponents();
closeAllSerials

setupDBPaths();
%would like to have these taken care of in setupEnvironment(), but some java problem seems to conflict with making the rnet (addJavaComponents() does update the path, but the import fails to make the class def's visible)
%<i think there used to be references to addJavaComponents here?>
%ListenChar(2);
%FlushEvents('keyDown');
