function img = deconvg6s(frames, dt);
%dt = 0.1
t = (0:9)*dt;
tau = [0.18 0.55];
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

imgdecon = cell(size(frames,4),1);
tic

parfor y = 1:size(frames,4)
for x = 1:size(frames,3)
    
    
        d = deconvlucy(squeeze(frames(1,:,x,y)),psf);
        imgdecon{y}(1,1:dlength-5,x) = d(6:dlength);
    end
end


img(1,1:dlength-5,:,:) = shiftdim(cell2mat(imgdecon),1);
toc

if nd==3
   img = squeeze(img);
end

