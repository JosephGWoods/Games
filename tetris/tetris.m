function tetris()
%% Tetris
% 02/03/2015
% Written by Joseph Woods

%% Initialise

scoreBoard = which('tetris_high_score.mat');
load(scoreBoard)

width  = 15;
height = 28;
fps    = 24; % Frames per second
delay  = 1/fps;

KeyStatus = false(1,7);
KeyStatusKeyUp = false(1,7);
KeyNames = {'uparrow','downarrow','leftarrow', 'rightarrow', 'alt', 'control', 'p'}; % The keyboard controls
KEY.SPINCLOCKWISE       = 1;
KEY.SPINANTICLOCKWISE   = 2;
KEY.MOVELEFT            = 3;
KEY.MOVERIGHT           = 4;
KEY.FASTDROP            = 5;
KEY.SLOWDROP            = 6;
KEY.PAUSE               = 7;

cmap = [0         0         0
        0.9047    0.1918    0.1988
        0.2941    0.5447    0.7494
        0.3718    0.7176    0.3612
        1.0000    0.5482    0.1000
        0.8650    0.8110    0.4330
        0.6859    0.4035    0.2412
        0.9718    0.5553    0.7741];

window = figure('name', 'Tetris', ...
                'units', 'normalized', 'position', [0.3 0.1 width/33 height/35], ...
                'menubar', 'none', ...
                'KeyPressFcn', @MyKeyDown, 'KeyReleaseFcn', @MyKeyUp);
set(window,'Renderer','opengl');
colormap(cmap)   % Use custom colormap
whitebg([0 0 0]) % Make the background black (to set back to white, just enter 'whitebg' into the command window)
rng('shuffle')   % Set random number generator

while true
    border       = 2; %border of 2 zeros on each side and on the bottom
    endcondition = 0;
    flag         = 0;
    score        = 0;
    level        = 1;
    tetrisFlag   = 0;
    time         = 0.3;
    threshold    = 2000; %Score threshold when game speeds up
    updateGame   = false;
    newShape     = [];
     
    subplot(3,3,[1,2,4,5,7,8])
    game         = zeros(height+border,width+2*border); %The game area with border
    imageH       = image(game(border+1:height,border+1:width+border));
    scoreText    = text(1      , 1, ['Score ',num2str(score)], 'color', [1,1,1], 'FontSize', 14); %Display the score
    levelText    = text(width-2, 1, ['Level ',num2str(level)], 'color', [1,1,1], 'FontSize', 14); %Display the level
    axis off
    drawnow
    
    subplot(3,3,3)
    [game,shape,shapeInd,shaperow,shapecol,xleft,xright,rowtop,rowbottom,dy,flag,endcondition,newShape,previewNewShape] = new_shape(game,width,border,flag,endcondition,newShape);
    imageShapeH = image(previewNewShape);
    text(1, 0, 'Shape preview', 'color', [1,1,1], 'FontSize', 16);
    axis off
    drawnow
    
    subplot(3,3,[1,2,4,5,7,8])
    
    %Time
    t_d = tic;
    while endcondition == 0
        
        %% Pause
        if KeyStatus(KEY.PAUSE)
            pauseText = text(1,height/2,{'Paused...','Press p to resume'},'color',[1 1 1],'FontSize',30);
            KeyStatus = false(1,7);
            KeyStatusKeyUp = false(1,7);
            while ~KeyStatus(KEY.PAUSE)
                waitforbuttonpress;
            end
            delete(pauseText);
            KeyStatus = false(1,7);
            KeyStatusKeyUp = false(1,7);
        end
            
        
        %% New Shape
        if flag == 0
            [game,shape,shapeInd,shaperow,shapecol,xleft,xright,rowtop,rowbottom,dy,flag,endcondition,newShape,previewNewShape] = new_shape(game,width,border,flag,endcondition,newShape);
            imageShapeH.CData = previewNewShape;
            drawnow
        end
        
        %% User input and lateral movement or spin
        
        if any(KeyStatus)
            updateGame = true;
        end
        
        if KeyStatus(KEY.FASTDROP)
            while flag == 1
                [game,rowtop,rowbottom,flag,dy] = move_down(game,shape,shapeInd,shaperow,shapecol,rowtop,rowbottom,xleft,xright,dy,height,flag);
            end
            KeyStatus(KEY.FASTDROP) = false;
            KeyStatusKeyUp(KEY.FASTDROP) = false;
        end
        if KeyStatus(KEY.SLOWDROP)
            [game,rowtop,rowbottom,flag,dy] = move_down(game,shape,shapeInd,shaperow,shapecol,rowtop,rowbottom,xleft,xright,dy,height,flag);
            if KeyStatusKeyUp(KEY.SLOWDROP)
                KeyStatus(KEY.SLOWDROP) = false;
                KeyStatusKeyUp(KEY.SLOWDROP) = false;
            end
        end
        if KeyStatus(KEY.MOVELEFT)
            dx = -1;
            [game,xleft,xright] = move_lateral(game,shape,shapeInd,shaperow,shapecol,rowtop,rowbottom,xleft,xright,width,border,dx);
            KeyStatus(KEY.MOVELEFT) = false;
            KeyStatusKeyUp(KEY.MOVELEFT) = false;
        end
        if KeyStatus(KEY.MOVERIGHT)
            dx = 1;
            [game,xleft,xright] = move_lateral(game,shape,shapeInd,shaperow,shapecol,rowtop,rowbottom,xleft,xright,width,border,dx);
            KeyStatus(KEY.MOVERIGHT) = false;
            KeyStatusKeyUp(KEY.MOVERIGHT) = false;
        end
        if KeyStatus(KEY.SPINCLOCKWISE)
            spin = 1;
            [game,shape,shapeInd,shaperow,shapecol,rowbottom,xright] = spin_shape(game,shape,spin,shaperow,shapecol,rowtop,rowbottom,xleft,xright,width,height,border);
            KeyStatus(KEY.SPINCLOCKWISE) = false;
            KeyStatusKeyUp(KEY.SPINCLOCKWISE) = false;
        end
        if KeyStatus(KEY.SPINANTICLOCKWISE)
            spin = -1;
            [game,shape,shapeInd,shaperow,shapecol,rowbottom,xright] = spin_shape(game,shape,spin,shaperow,shapecol,rowtop,rowbottom,xleft,xright,width,height,border);
            KeyStatus(KEY.SPINANTICLOCKWISE) = false;
            KeyStatusKeyUp(KEY.SPINANTICLOCKWISE) = false;
        end
        if updateGame
            imageH.CData = game(border+1:height,border+1:width+border);
            drawnow
        end
        
        %% Downward movement
        if toc(t_d) > time
            [game,rowtop,rowbottom,flag,dy] = move_down(game,shape,shapeInd,shaperow,shapecol,rowtop,rowbottom,xleft,xright,dy,height,flag);
            imageH.CData = game(border+1:height,border+1:width+border);
            drawnow
            t_d = tic;
        end
        
        %% Delete rows that are full
        %Delete any rows that are full and replace them with zero-filled rows at the top
        if dy == 0 && ~isempty(find(all(game(1:height,border+1:width+border)~=0,2),1))
            lostRows = length(find(all(game(1:height,border+1:width+border)~=0,2)));
            game(all(game(1:height,border+1:width+border)~=0,2),:)=[];
            game = [zeros(lostRows,width+2*border);game];
            
            %Update score
            bonus = 0;
            if     lostRows == 1; bonus = 100;
            elseif lostRows == 2; bonus = 300;
            elseif lostRows == 3; bonus = 500;
            elseif lostRows == 4
                if tetrisFlag == 0; bonus = 800;
                else;               bonus = 800 + (400*tetrisFlag); end
            end
            score = score + level*bonus;
            lostRows = 0; %Reset lostRows
            
            % Update tetrisFlag
            %tetrisFlag shows how many times in a row a tetris has been achieved
            if lostRows == 4; tetrisFlag = tetrisFlag + 1;
            else; tetrisFlag = 0; end
            
            %If a multiple of 2000 points has been reached, then speed up the game
            if score >= threshold
                threshold = threshold + 2000; time = time-0.02; level = level + 1;
            end
            
            scoreText.String = ['Score ',num2str(score)]; %Display the score
            levelText.String = ['Level ',num2str(level)]; %Display the level
        end
        
        pause(delay)
    end
    
    %% Display losing statement
    uicontrol('units','normalized','Position',[0.2 0.5 0.6 0.08],'style','text','string','YOU LOSE','FontSize',25)
    
    % Score board
    % Score board written by Jim Smith, amended by Joseph Woods
    pause(1)
    clf
    
    % Highscore => append to current => sort => chop off the last one
    ent_val=0;
    if score > cell2mat(h_score(5,2))
        uicontrol('units','normalized','Position',[0.2 0.8 0.6 0.065],'style','text','string','New High Score','FontSize',20)
        ent_name=uicontrol('units','normalized','Position',[0.2 0.6 0.2 0.065],'style','edit','string','Name','FontSize',10);
        uicontrol('units','normalized','Position',[0.6 0.6 0.2 0.065],'style','text','string',num2str(score),'FontSize',10)
        ent_button=uicontrol('units','normalized','Position',[0.4 0.6-0.065 0.2 0.065],'style','toggle','string','Submit','FontSize',10,'value',0);
        while ent_val == 0
            ent_val=get(ent_button, 'value');
            pause(0.00001)
        end
        h_score(6,1)    = {get(ent_name,'string')};
        h_score(6,2)    = {score};
        [h_score_s, Is] = sort(cell2mat(h_score(:,2)),'descend');
        names_s         = h_score(Is,1);
        h_score_s       = num2cell(h_score_s);
        h_score         = [names_s,h_score_s];
        h_score         = h_score(1:5,:);
        save(scoreBoard,'h_score')
    end
    
    clf
    uicontrol('units','normalized','Position',[0.2 0.8 0.6 0.065],'style','text','string','High Scores','FontSize',20,'fontname','OCR A Extended')
    
    %Names
    uicontrol('units','normalized','Position',[0.25 0.7 0.2 0.04],'style','text','string',h_score(1,1),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('units','normalized','Position',[0.25 0.6 0.2 0.04],'style','text','string',h_score(2,1),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('units','normalized','Position',[0.25 0.5 0.2 0.04],'style','text','string',h_score(3,1),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('units','normalized','Position',[0.25 0.4 0.2 0.04],'style','text','string',h_score(4,1),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('units','normalized','Position',[0.25 0.3 0.2 0.04],'style','text','string',h_score(5,1),'FontSize',15,'fontname','OCR A Extended')
    
    %scores
    uicontrol('units','normalized','Position',[0.55 0.7 0.2 0.04],'style','text','string',h_score(1,2),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('units','normalized','Position',[0.55 0.6 0.2 0.04],'style','text','string',h_score(2,2),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('units','normalized','Position',[0.55 0.5 0.2 0.04],'style','text','string',h_score(3,2),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('units','normalized','Position',[0.55 0.4 0.2 0.04],'style','text','string',h_score(4,2),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('units','normalized','Position',[0.55 0.3 0.2 0.04],'style','text','string',h_score(5,2),'FontSize',15,'fontname','OCR A Extended')
    
    restart_butt=uicontrol('units','normalized','Position',[0.25 0.15 0.5 0.06],'style','toggle','string','Play Again?','FontSize',15,'fontname','OCR A Extended','value',0);
    restart=0;
    while restart==0
        restart=get(restart_butt, 'value');
        pause(delay)
    end
    clf
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Nested functions %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Key press events
    function MyKeyDown(hObject, ~, ~)
        key = get(hObject,'CurrentKey');
        KeyStatus = (strcmp(key, KeyNames) | KeyStatus);
        KeyStatusKeyUp = (~strcmp(key, KeyNames)) & KeyStatusKeyUp;
    end
    function MyKeyUp(hObject, ~, ~)
        key = get(hObject,'CurrentKey');
        KeyStatusKeyUp = strcmp(key, KeyNames) | KeyStatusKeyUp;
        %KeyStatus = (~strcmp(key, KeyNames)) & KeyStatus;
    end

    %% Generate Tetris shape
    function [shape] = tetrisShape(p)
        n = 7;
        m = 1:n;
        if p <= m(1)/n                      % Line
            shape = round([0 0 0 0;m(1) m(1) m(1) m(1);0 0 0 0])';
        elseif p > m(1)/n && p <= m(2)/n    % Square
            shape = round([m(2) m(2);m(2) m(2)]);
        elseif p > m(2)/n && p <= m(3)/n    % L
            shape = round([m(3) 0;m(3) 0;m(3) m(3)]);
        elseif p > m(3)/n && p <= m(4)/n    % backwards L
            shape = round([0 m(4);0 m(4);m(4) m(4)]);
        elseif p > m(4)/n && p <= m(5)/n    % T
            shape = round([m(5) m(5) m(5);0 m(5) 0]);
        elseif p > m(5)/n && p <= m(6)/n    % backwards Z
            shape = round([0 m(6) m(6);m(6) m(6) 0]);
        elseif p > m(6)/n && p <= m(7)/n    % Z
            shape = round([m(7) m(7) 0;0 m(7) m(7)]);
        end
        shape(shape>0) = shape(shape>0) + 1;
    end

    %% New shape
    function [game,shape,shapeInd,shaperow,shapecol,xleft,xright,rowtop,rowbottom,dy,flag,endcondition,newShape,previewNewShape] = new_shape(game,width,border,flag,endcondition,nextShape)
        newShape = tetrisShape(rand); %Generate the new shape
        shape = nextShape;
        if isempty(shape)
            shape = newShape;
        end
        
        % Get the details of the nextShape
        xleft = round(width/2)-floor((size(shape,2)-1)/2)+border;  %Find the left and right-hand edge placement (the column indices) of the shape in the game (it's placed in the middle)
        xright = round(width/2)+floor(size(shape,2)/2)+border;
        rowtop = 1; %Find the top and bottom edge placement (the row indices) of the shape in the game (it's placed at the top)
        rowbottom = rowtop+floor(size(shape,1))-1;
        dy = 1; %Initial y movement, i.e. move down 1 element
        
        % Generate the preview of the newShape
        siz = size(newShape);
        padSize(1) = floor((7-siz(1))/2);
        padSize(2) = floor((7-siz(2))/2);
        previewNewShape = padarray(newShape,padSize,'pre');
        padSize(1) = ceil((7-siz(1))/2);
        padSize(2) = ceil((7-siz(2))/2);
        previewNewShape = padarray(previewNewShape,padSize,'post');
        
        %Check that the entry area is not occupied
        [shaperow,shapecol] = find(shape~=0); %Find the values of the shape that are not zero
        shapeInd = sub2ind(size(shape),shaperow,shapecol); %Find the indices that these row and col vetors relate to
        gameInd = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1); %Find the indices in the game where the shape will go
        if sum(sum(game(gameInd))) == 0
            game(gameInd) = shape(shapeInd); %Update the entry position with the shape
            flag = 1;
        else
            endcondition = 1; %If the entry area is occupied, then end the game
        end
    end

    %% Move down
    function [game,rowtop,rowbottom,flag,dy] = move_down(game,shape,shapeInd,shaperow,shapecol,rowtop,rowbottom,xleft,xright,dy,height,flag)
        %If the bottom has been reached
        if rowbottom >= height && sum(game(height,xleft:xright)) ~= 0
            dy = 0;
            flag = 0;
            gameInd = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1);
        else
            %This is to clear where the current shape is, in order to make the checks ahead easier.
            gameInd = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1);
            game(gameInd) = 0;
            
            gameIndbelow = sub2ind(size(game),shaperow+rowtop-1+dy,shapecol+xleft-1);
            if sum(sum(game(gameIndbelow))) ~= 0 %If there is a shape in the next position
                dy = 0; %Stop the shape moving down if there is a shape below it
                flag = 0; %Set the flag for a new shape to be created
            end
        end
        %Update only if still moving down
        if dy ~= 0
            gameIndNew = sub2ind(size(game),shaperow+rowtop-1+dy,shapecol+xleft-1); %Update the placement area of the shape
            game(gameIndNew) = shape(shapeInd);
            %Update position
            rowtop = rowtop+dy;
            rowbottom = rowbottom+dy;
        else
            game(gameInd) = shape(shapeInd); %If not moving down, then just place the shape as it was
        end
    end

    %% Move horizonatally
    function [game,xleft,xright] = move_lateral(game,shape,shapeInd,shaperow,shapecol,rowtop,rowbottom,xleft,xright,width,border,dx)
        %If the left or right edge has been reached
        if xleft+dx <= border && sum(sum(game(rowtop:rowbottom,1:border+1))) ~= 0 || xright+dx >= width+border+1 && sum(sum(game(rowtop:rowbottom,width+border:width+2*border))) ~= 0
            dx = 0;
        end
        %This is to clear where the current shape is, in order to make the checks ahead easier.
        gameInd = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1);
        game(gameInd) = 0;
        gameIndlateral = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1+dx);
        if sum(sum(game(gameIndlateral))) ~= 0 %If there is a shape in the next position
            dx = 0; %First stop any possible lateral movement
        end
        %Update game only if still moving laterally
        if dx ~= 0
            gameIndNew = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1+dx); %Update the placement area of the shape
            game(gameIndNew) = shape(shapeInd);
        else
            game(gameInd) = shape(shapeInd); %If not moving down, then just place the shape as it was
        end
        %Update position
        xleft = xleft+dx;
        xright = xright+dx;
    end

    %% Spin shape
    function [game,shape,shapeInd,shaperow,shapecol,rowbottom,xright] = spin_shape(game,shape,spin,shaperow,shapecol,rowtop,rowbottom,xleft,xright,width,height,border)
        %This is to clear where the current shape is, in order to spin the shape
        gameInd = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1);
        game(gameInd) = 0;
        dim = size(shape); %Retain previous dimensions of the shape (some of the shapes are not square matrices)
        %Rotate shape and get new indices for it
        shape = rot90(shape,spin);
        [shaperow,shapecol] = find(shape~=0);
        shapeInd = sub2ind(size(shape),shaperow,shapecol);
        gameInd = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1);
        rowbottomNew = rowtop + max(shaperow) - 1; %Possible new rowbottom and xright (rowtop and xleft remain the same during rotation)
        xrightNew = xleft + max(shapecol) - 1;
        %Check to see if new position is occupied or outside the edge or off the bottom, if it is then spin it back
        if sum(game(gameInd)) ~= 0 || min(shapecol)+xleft-1 <= border || xrightNew > width + border || rowbottomNew >= height
            shape = rot90(shape,-spin);
            [shaperow,shapecol] = find(shape~=0);
            shapeInd = sub2ind(size(shape),shaperow,shapecol);
            gameInd = sub2ind(size(game),shaperow+rowtop-1,shapecol+xleft-1);
        elseif size(shape,2) ~= dim(2) %Update the rowbottom and xright
            rowbottom = rowbottomNew;
            xright = xrightNew;
        end
        %Update game in order to check lateral and vertical movement in the next section
        game(gameInd) = shape(shapeInd);
    end

end
