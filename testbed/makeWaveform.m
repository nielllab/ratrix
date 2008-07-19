
%%
biggest=128;
pixPerCyc=32;
phase=0;
waveform={'sine','matchFrequency','natural','square','matchFrequencyThresh','naturalThresh'};

path='\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\matlab creation files\CatCam\labelb000530a';
file='Catt0001.tif'
im=imread(fullfile(path, file));
ypos=floor(size(im,2)/2);
natLine=im(ypos,1:biggest);

for i=1:length(waveform)
    switch waveform{i}
        case 'sine'
            line = sin(phase  + (0:biggest*2)*(2*pi)/pixPerCyc/2);
        case 'square'
            %this may look crazy to you, but i defy you to find a
            %simpler solution.  make sure it works for negative phases!
            % and it should match the phase of the sine version.  we
            % couldn't just sign(sin()) cuz of numerical instability.
            %                               -the management
            sqPhase = phase + (ceil(abs(phase/(2*pi)))+1)*2*pi;

            sqPixPerCycs=pixPerCyc*2;
            line = rem(([0:biggest*2]+sqPhase*sqPixPerCycs/(2*pi)+sqPixPerCycs/2)/sqPixPerCycs,1)>=.5;
            line=line-.5;

            %if you'd like to try for yourself, here are some ideas:
            % phase = phase + (ceil(abs(phase/(2*pi)))+1)*2*pi;
            % a=rem(([0:len]+phase*pixPerCyc/(2*pi)+pixPerCyc/2)/pixPerCyc,1)>=.5;
            % a=2*a-1;
            % b=sin(phase  + (0:len)*(2*pi)/pixPerCyc);
            %
            % plot([a;b]')
        case 'natural'
            line=natLine;

        case 'matchFrequency'
            h=fft2(double(natLine));
            phaseIm=rand(size(natLine))*2*pi;
            magIm=abs(h);
            newComplex=magIm.*sin(phaseIm)+magIm.*cos(phaseIm);
            testComplex=h;
            half=floor(size(h,2)/2)
            line=abs(ifft2(newComplex));
            %line=abs(ifft2(testComplex)); %this should be the remade stimulus, and it is
            matchFrequencyLine=resample(line(1:half),2,1); %get rid of the symmetry
            line=matchFrequencyLine;
            %the problem is somewhere we have a symmetric representation of frequency,
            %and it is not transforming back correctly
            %maybe this is the case for random phase

        case 'matchFrequencyThresh'
            %             h=fft2(double(natLine));
            %             phaseIm=rand(size(natLine))*2*pi;
            %             magIm=abs(h);
            %             newComplex=magIm.*sin(phaseIm)+magIm.*cos(phaseIm);
            %             testComplex=h;
            %             half=floor(size(h,2)/2)
            %             line=abs(ifft2(newComplex));
            %             %line=abs(ifft2(testComplex)); %this should be the remade stimulus, and it is
            %             line=resample(line(1:half),2,1); %get rid of the symmetry

            sorted=sort(matchFrequencyLine);
            half=floor(size(matchFrequencyLine,2)/2);
            midpoint=sorted(half);
            line=matchFrequencyLine>midpoint;

        case 'naturalThresh'
            sorted=sort(natLine);
            half=floor(size(natLine,2)/2);
            midpoint=sorted(half);
            line=natLine>midpoint;




    end

    figure(1);
    subplot(2,3,i)
    imagesc(line)
    axis square
    colormap(gray)
    set(gca, 'xTick', [])
    set(gca, 'YTick', [])
    xLabel(waveform{i})
end

%%