function img = deconvg6s(frames, dt);
%%% does lucy deconvolution
%%% works on n-d images (or timecourse)
%%% but first dimension has to be time

%dt = 0.1
t = (0:9)*dt;
tau = [0.18 0.55];
tau = [0.05 0.55];
psf = (1-exp(-t/tau(1))).*exp(-t/tau(2));
psf = psf/sum(psf);
% figure
% plot(psf)

if ndims(frames)==3
    nd=3;
    fr = zeros(1,size(frames,1),size(frames,2),size(frames,3));
    fr(1,:,:,:)=frames;
    frames=fr;
else
    nd=4;
end

dlength = size(frames,2);

img = zeros(size(frames));
display('deconvolving ...');

% for x = 1:size(frames,3)
%     
%     for y = 1:size(frames,4)
%         d = deconvlucy(squeeze(frames(1,:,x,y)),psf);
%         img(1,1:dlength-5,x,y) = d(6:dlength);
%     end
% end

img = deconvlucy(frames,psf);
img = img(:,6:end,:,:);

%keyboard
if nd==3
   img = squeeze(img);
end

