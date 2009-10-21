classdef PatchVideo
    % PatchVideo makes videos of image feature-lets;  
    % and intuition pump for contextual processing of visual features
    %   note: requires computeGabors.m to run
    %   p=PatchVideo; p=p.MakeMove; p.ExportAVI
    properties
        interOnsetInterval=1;  %frames
        patchDuration=4;  %frames
        numFrames=200;
        maskType='gauss';
        maskSize=25;
        movieWidth=512;
        movieHieght=512;
        
        sourceImages={'cow1.jpg'}%,'horse1.jpg'} %input
        movies  % to be filled in with data
    end
    
    properties
        numMovies
        numPatches
    end
    methods
        
        function out=get.numMovies(this)
            out=length(this.sourceImages)
        end
        function out=get.numPatches(this)  
            out=floor(this.numFrames/this.interOnsetInterval)+1;
        end
        function this=MakeMove(this)
            figure
            set(gcf,'Position',[50 50 this.movieWidth this.movieHieght])
            
            
            %choose random patch locations - conserved locations across movies
            patchX=rand(1,this.numPatches);
            patchY=rand(1,this.numPatches);
            specialCowStart=true;
            if specialCowStart
                which=2;
                switch which
                    case 1
                        patchX(1)=0.29;
                        patchY(1)=0.42;
                        patchX(2)=0.37;
                        patchY(2)=0.28;
                        %patchX(3)=0.4;
                        %patchY(3)=0.25;
                    case 2
                        patchX(1)=0.3;
                        patchY(1)=0.4;
                        patchX(2)=0.3;
                        patchY(2)=0.6;
                        %patchX(3)=0.3;
                        %patchY(3)=0.5;
                end
            end
            
            for i=1:this.numMovies
                
                %load the image
                im=imread(this.sourceImages{i});
                im=rgb2gray(im);
                im=imresize(im,[this.movieWidth this.movieHieght]);
                imageMean=mean(im(:));  % could force to 128... using empiric for now
                blankImage=imageMean(ones(this.movieHieght,this.movieWidth));
                upImage=double(im-imageMean);
                downImage=double(imageMean-im);
                
                patchStarts=1:this.interOnsetInterval:this.numFrames;
                patchStops=patchStarts+this.patchDuration-1;
                %this.movies{i}=movie;
                for j=1:this.numFrames
                    patchesOn=find(patchStarts<=j & patchStops>=j);
                    if j>=this.numFrames-this.patchDuration
                        %last frame has all of them on
                        patchesOn=1:this.numPatches;
                    end
                    
                    if ~isempty(patchesOn)
                        %compute buble mask
                        switch this.maskType
                            case 'gauss'
                                params=99*ones(length(patchesOn),8);  %initialize with useless values
                                params(:,1)=this.maskSize/this.movieHieght;  %fill in radius
                                params(:,5)=1;  %fill in contrast
                                params(:,6)=0.001;  %fill in threshold
                                params(:,7)=patchX(patchesOn);
                                params(:,8)=patchY(patchesOn);
                                mask=computeGabors(params,0,this.movieWidth,this.movieHieght,'none','normalizeVertical',false,true);
                            otherwise
                                error('bad mask type')
                        end
                    else
                        %no patches will be blank
                        mask=zeros(this.movieHieght,this.movieWidth);
                    end
                    
                    %apply bubble mask
                    bubbles=blankImage+upImage.*mask-downImage.*mask;
                    
                    
                    imagesc(bubbles,[0 255]); colormap(gray)
                    set(gca,'xTickLabel',[],'yTickLabel',[],'TickLength',[0 0]);
                    axis square
                    this.movies{i}(j)=getframe;
                    fprintf('movie: %d  frame: %d patchesThisFrame: %d\n',i,j,length(patchesOn))
                    
                    if (j==1 || j==this.numFrames) && 0
                        keyboard
                    end
                end
            end
        end
        
        function PlayMovie(this,which)
           movie(this.movies{which})
        end
        
        function ExportAVI(this)
            for i=1:this.numMovies
                [junk filename]=fileparts(this.sourceImages{i});
                movie2avi(this.movies{i},filename);
            end
        end
    end
    
end

