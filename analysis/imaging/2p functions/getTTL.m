function [stimPulse framePulse] = getTTL(fname)
load(fname,'bin','hz','state');
sprintf('ttl file name %s',state.files.fullFileName)
stimEdge = diff(bin(:,2));
stimPulse = find(stimEdge>0)/hz;
frameEdge = diff(bin(:,1));
framePulse = find(frameEdge>0)/hz;
