function clearTest

s = max(Screen('Screens'));

w = Screen('OpenWindow',s,BlackIndex(s));

white = WhiteIndex(w)*ones(1,3);
grey = .5*white;

scrRect = Screen('Rect', w); %left top right bottom

r = scrRect;
r([1 3]) = [100 200];

while ~KbCheck
    
    Screen('FillRect', w, grey, r);
    Screen('FillRect', w, white, r+200*[1 0 1 0]);
    
    if rand > .9
        %should only transiently grey the screen, then undone by flip's window clearing.  but instead it is permanent once tripped!
        k = scrRect;
        
        rescue = false; %problem only occurs reliably when rect is full screen, otherwise it is nondeterministic
        if rescue
            k = k-[0 0 1 0];
        end
        
        Screen('FillRect',w,grey,k);
    end
    
    Screen('Flip',w,[],double(rand>.3));
    
    WaitSecs(.5);
    
    r = r + 10*[1 0 1 0];
end

Screen('CloseAll');
end