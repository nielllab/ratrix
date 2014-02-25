function img = deconvg6s(frames, dt);
%dt = 0.1
t = (0:9)*dt;
tau = [0.18 0.55];
psf = (1-exp(-t/tau(1))).*exp(-t/tau(2));
psf = [zeros(1,9) psf];
figure
plot(psf)

img = zeros(size(frames));
for x = 1:size(frames,3)
    x
    for y = 1:size(frames,4)
        d = deconvlucy(squeeze(frames(1,:,x,y)),psf);
        img(1,:,x,y) = d;
    end
end