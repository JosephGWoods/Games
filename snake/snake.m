function snake()
% James Smith & Martin Hailstone & Joseph Woods
% 02/03/2015
% Snake Game

numCTRLS = 5;
KeyStatus = false(1,numCTRLS);
KeyNames = {'uparrow','downarrow','leftarrow','rightarrow','p'}; % The controls
KEY.MOVEUP     = 1;
KEY.MOVEDOWN   = 2;
KEY.MOVELEFT   = 3;
KEY.MOVERIGHT  = 4;
KEY.PAUSE      = 5;

load('ONBI_h_score.mat')

width=15;
%map=zeros(width);
window=figure('position',[100 100 500 500],'menubar','none','KeyPressFcn', @MyKeyDown);
set(gcf,'Renderer','OpenGL');
supercolourmap=colormap(jet(width.^2));
cmap=zeros(width^2+2,3);
while true
    figure(window)
    map=zeros(width);
    frontx=10;
    fronty=10;
    cont=1;
    slength=4;
    
    foodno=width^2+2;
    
    foodpresent=0;
    dx=0;
    dy=1;
    
    hMap = image(map); colormap(cmap);
    score=(slength-4)*10;
    hText = text(1,1, ['Score ',num2str(score)],'color',[1 1 1]);
    axis off
    
    
    while cont==1
        t_s=tic;
        
        % Pause
        if KeyStatus(KEY.PAUSE)
            pauseText = text(1,width/2,{'Paused...','Press p to resume'},'color',[1 1 1],'FontSize',30);
            KeyStatus = false(1,numCTRLS);
            while ~KeyStatus(KEY.PAUSE)
                waitforbuttonpress;
            end
            KeyStatus = false(1,numCTRLS);
            delete(pauseText);
        end
        
        if KeyStatus(KEY.MOVEUP) && dy~=1
            dy=-1;
            dx=0;
        end
        if KeyStatus(KEY.MOVEDOWN) && dy~=-1
            dy=1;
            dx=0;
        end
        if KeyStatus(KEY.MOVERIGHT) && dx~=-1
            dy=0;
            dx=1;
        end
        if KeyStatus(KEY.MOVELEFT) && dx~=1
            dy=0;
            dx=-1;
        end

        fronty=fronty+dy;
        frontx=frontx+dx;
        
        if fronty>width
            fronty=1;
        elseif fronty<1
            fronty=width;
        end
        
        if frontx>width
            frontx=1;
        elseif frontx<1
            frontx=width;
        end
        
        if map(fronty,frontx)>=1 && map(fronty,frontx)<foodno
            uicontrol('Position',[165 225 200 50],'style','text','string','YOU DIED','FontSize',25)
            cont=0;
        elseif map(fronty,frontx)==foodno
            foodpresent=0;
            slength=slength+1;
            map(fronty,frontx)=slength;
        else
            map(fronty,frontx)=slength;
        end
        map(map~=foodno)=map(map~=foodno)-1;
        map(map<0)=0;
        
        %%
        cmap=zeros(width^2,3);
        xq=mat2gray(0:(slength-1))*width^2+1;
        minicolourmap=interp1(1:width^2,supercolourmap,xq,'nearest');
        cmap(2:1+slength,:)=minicolourmap;
        
        cmap(end,:)=[1;1;1];
        
        %%
        
        
        hMap.CData = map;colormap(cmap)
        score=(slength-4)*10;
        hText.String = ['Score ',num2str(score)];
        pt=0.07-toc(t_s);
        pt(pt<0)=0;
        pause(pt)
        
        if foodpresent==0
            ind=find(map==0);
            food = randsample(ind,1);
            map(food)=width^2+3;
            foodpresent=1;
        end
    end
    pause(3)
    clf
    % Highscore => append to current => sort => chop off the last one
    ent_val=0;
    if score>cell2mat(h_score(5,2))
        uicontrol('Position',[100 400 300 50],'style','text','string','New High Score','FontSize',25)
        ent_name=uicontrol('Position',[100 300 100 50],'style','edit','string','Name','FontSize',15);
        uicontrol('Position',[300 300 100 50],'style','text','string',num2str(score),'FontSize',15)
        ent_button=uicontrol('Position',[200 250 100 50],'style','toggle','string','Submit','FontSize',15,'value',0);
        while ent_val==0;
            ent_val=get(ent_button, 'value');
            pause(0.00001)
        end
        h_score(6,1)={get(ent_name,'string')};
        h_score(6,2)={score};
        [h_score_s, Is]=sort(cell2mat(h_score(:,2)),'descend');
        names_s=h_score(Is,1);
        h_score_s=num2cell(h_score_s);
        h_score=[names_s,h_score_s];
        
        h_score=h_score(1:5,:);
        save('ONBI_h_score.mat','h_score')
    end
    
    clf
    uicontrol('Position',[100 400 300 50],'style','text','string','High Scores','FontSize',25,'fontname','OCR A Extended')
    
    %Names
    uicontrol('Position',[120 300 100 40],'style','text','string',h_score(1,1),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('Position',[120 250 100 40],'style','text','string',h_score(2,1),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('Position',[120 200 100 40],'style','text','string',h_score(3,1),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('Position',[120 150 100 40],'style','text','string',h_score(4,1),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('Position',[120 100 100 40],'style','text','string',h_score(5,1),'FontSize',15,'fontname','OCR A Extended')
    
    %scores
    uicontrol('Position',[260 300 100 40],'style','text','string',h_score(1,2),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('Position',[260 250 100 40],'style','text','string',h_score(2,2),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('Position',[260 200 100 40],'style','text','string',h_score(3,2),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('Position',[260 150 100 40],'style','text','string',h_score(4,2),'FontSize',15,'fontname','OCR A Extended')
    uicontrol('Position',[260 100 100 40],'style','text','string',h_score(5,2),'FontSize',15,'fontname','OCR A Extended')
    
    restart_butt=uicontrol('Position',[190 50 150 40],'style','toggle','string','Play Again?','FontSize',15,'fontname','OCR A Extended','value',0);
    restart=0;
    while restart==0
        restart=get(restart_butt, 'value');
        pause(0.000000001)
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
        KeyStatus = strcmp(key, KeyNames);
    end

end