numCons = [1:1:7];

clear c
for c = numCons 
    figure
    imshow(stimulus(:,:,c));
    drawnow
    
    % save plot
    nthFileName = sprintf('%d_Con.png',numCons(c));
    print(nthFileName,'-dpng')

end

