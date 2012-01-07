function [movie dotsxy]=cdots(nDots,width,height,nFrames,coherence,speed,direction,shape,uniformSpeed)
% example:
%
% nDots     = 75;
% width     = 300;
% height    = 100;
% nFrames   = 200;
% coherence = .85;
% speed     = .005;
% direction = -3*pi/4;
% shape     = [0 1 0; ...
%              1 0 1; ...
%              0 1 0; ...
%             ];
% uniformSpeed = true;
% m = cdots(nDots,width,height,nFrames,coherence,speed,direction,shape,controlSpeed);
% for i=1:size(m,3)
%   imagesc(m(:,:,i))
%   axis equal
%   pause(.01)
% end

jump = rand(nFrames, nDots) > coherence;
jump(1,:) = true;
inds = find(jump);

dotsxy = zeros(nFrames, nDots, 2);
dotsxy([inds inds+(nFrames*nDots)]) = rand(1,2*length(inds));

speed = reshape(speed * [height/width 1],[1 1 2]);
d = speed .* components(direction);

    function out=components(angle)
        out = reshape(cell2mat(cellfun(@(f) f(angle(:)),{@cos @sin},'UniformOutput',false)),[1 numel(angle) 2]);
    end

for i=2:nFrames %use cumsum to eliminate loop
    if uniformSpeed
        inds = jump(i,:);
        dotsxy(i,inds,:) = dotsxy(i-1,inds,:) + repmat(speed,1,sum(inds)).*components(2*pi*dotsxy(i,inds,1));
    end
    
    inds = ~jump(i,:);
    dotsxy(i,inds,:) = dotsxy(i-1,inds,:) + repmat(d,[1 sum(inds) 1]);
end

dotsxy = 1 + round(mod(dotsxy,ones(size(dotsxy))) .* repmat(reshape([width height]-1,[1 1 2]),nFrames,nDots));

movie = zeros(height,width,nFrames);
movie(sub2ind(size(movie),dotsxy(:,:,2),dotsxy(:,:,1),repmat(1:nFrames,nDots,1)')) = 1;
movie = convn(movie,shape,'same') ~= 0;
end