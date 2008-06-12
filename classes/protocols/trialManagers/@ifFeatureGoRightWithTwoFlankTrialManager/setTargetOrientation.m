function t=setTargetOrientation(t, orientations, updateNow)

% trialManager =setTargetOrientation(trialManager, [0, pi/2; 0, pi/2])

if ~exist('updateNow', 'var')
    updateNow = 1;
end

if size(orientations,1) == 1
    orientations = repmat(orientations, 2, 1); % if only one list of orientations apply to left and right
end 

t.goRightOrientations = orientations(1,:);
t.goLeftOrientations = orientations(2,:);



if updateNow
t = deflate(t);
t = inflate(t);
end
