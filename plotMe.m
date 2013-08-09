function varargout = plotMe(init,flag,saveFlag,saveName,outputDir,data,parameters,varargin)
% This function generates plots and videos and calls the save routine if
% neccessary
% author: Felix Loosmann - TU Darmstadt
% version: 0.5
% loosmann@gsc.tu-darmstadt.de
%
% init = start new plot
% flag = kind of data
% saveFlag = save plot or not?
% saveName = name under that the plot will be saved
% data contains the x, y, z values and the time if appropriate
% parameters contains optional properties
%   e.g.    'legend', {'label1';'label2'}
%           'position', [x,y]
%           'title', 'created by plotMe'
% flag: 1, 2D plot
%       2, 3D plot
%       3, 2D video
%       4, 3D video -> not implemented
%       5, 2D subplot
%       6, 3D subplot -> not implemented
%       7, textbox
%
% additional settings can be made with varargin
% e.g. desired figure handle
% format: varargin = {'figHandle',4,'blackAndWhite',1,'formats',[1,2...,10],'resolution','300'}
% formats: 1, jpeg
%          2, png
%          3, fig
%          4, tiff
%          5, bmp
%          6, pdf
%          7, eps
%          8, epsc
%          9, eps2
%          10, epsc2
% resolution:
%     postScript and built-in raster formats, and Ghostscript vector format only. Specify resolution in dots per inch. Defaults to 90 for Simulink, 150 for figures in image formats and when printing in Z-buffer or OpenGL mode, screen resolution for metafiles, and 864 otherwise. Use -r0 to specify screen resolution. 

varargout{1} = []; % make sure that we return sth!



% open fig
figHandle = 4;
blackAndWhite = 0;
formats= [1,3];
resolution= '150';%dpi <- screen resolution, everything else will change the label font sizes etc
if nargin > 7    
    [names values] = parseArguments({'figHandle','blackAndWhite','formats','resolution'},varargin);    
    for i =1:length(names)
        if strcmpi('figHandle',names{i});
            figHandle = values{i};
        elseif strcmpi('blackAndWhite',names{i})
            blackAndWhite = values{i};
        elseif strcmpi('formats',names{i})
            formats=values{i};
        elseif strcmpi('resolution',names{i})
            resolution=values{i};
        end        
    end
else
    if nargin ~= 7 
        error('plotMe:input','Something is missing here');
    end
end
h = figure(figHandle);
set(0,'currentfigure',figHandle);
if blackAndWhite
    %colors = zeros(10,3);
    colors = [[0 0 0]/255;[83 83 83]/255;[137 137 137]/255;[181 181 181]/255;[220 220 220]/255];
    lineStyles = '-|--|:|-.';
    
else
    %colors = [[0 78 138]/255;[0 104 157]/255;[127 171 22]/255; [177 189 0]/255;[215 172 0]/255;[210 135 0]/255; [204 76 3]/255; [185 15 34]/255;[149 17 105]/255;[97 28 115]/255]; % CI colors TUD section III - 1c-11c
    colors = [[0 90 169]/255;[0 131 204]/255;[0 157 129]/255;[153 192 0]/255;[201 212 0]/255;[253 202 0]/255;[245 163 0]/255;[236 101 0]/255;[230 0 26]/255;[166 0 132]/255;[114 16 133]/255];% CI colors TUD section II - 1b-11b
    lineStyles = '-';
end
set(0,'DefaultAxesLineStyleOrder',lineStyles);
set(0,'defaultAxesColorOrder',colors);
% make fig invisible
% set(4,'Visible','off');
% init fig or keep data
if init
    clf;
else
    hold all;
end

% decide kind of plot
switch flag
    case 1 % 2D Plots
        set(0,'currentfigure',figHandle);             
        plot(data{1},data{2});
        adjustFig(figHandle,parameters);
        % save data if desired
%         saveAsMat(saveName,[data{1},data{2}]);
        % save as image
        if saveFlag
            savePlot(saveName,outputDir,formats,figHandle,resolution);             
        end
    case 2 % 3D Plot
        set(0,'currentfigure',figHandle);
        plot3(data{1},data{2},data{3});
        adjustFig(figHandle,parameters);
        % save data if desired
        saveAsMat(saveName,[data{1},data{2}]);
        % save as image
        savePlot(saveName);        
    case 3 % Video 2D
        set(0,'currentfigure',figHandle);
        hold all;       
        adjustFig(figHandle,parameters);
        frames = struct('cdata',{},'colormap',{});
        title(data{4},'Interpreter','Latex'); % plot destroies title object 
        x = data{1};
        y = data{2};
        ti = data{3};
        clear data parameters;
        textSize = hash.get('textFontSize');
        parfor q = 1:size(y,1)   
            set(0,'currentfigure',figHandle);
            line = plot(x, y(q,:),'b',x,y(q,:),'oc');            
            % set timestamp           
            t = text(0.73,-1.8, sprintf('Time: %3.1fs',ti(q)),...
                'Interpreter','Latex','FontSize',textSize,...
                'Backgroundcolor',get(gca,'color'));   
            % store frame
            frames(q) = getframe(figHandle);          
            delete(line,t); % delete last line, keep properties of axes etc..
        end
        % the next line command repeats every value of frames m = times
        % I increase frames m-times, because 1fps is the smallest value
            % I can set and otherwise you cannot see anything on the movie
        m = 10;        
        frames = reshape(repmat(frames',m,1), length(frames(1,:)), m*length(frames(:,1)))';
        movie2avi(frames,saveName,'fps','1');
        clear frames m x y ti line;
        clf; % a video figure should not be processed after saving the video!
    case 4 % Video 3D
        writeOutput(1,'plotMe:video3D','3D video creation is not implemented');
        hash = getpref('gui','hash');
    case 5 % Subplot 2D
        set(0,'currentfigure',figHandle);
        count = hash.get('subplotCount');   
        % resize window for subplot's
        if isempty(count)
            count = 6;
        end
        pos = get(4,'Position');
        set(4,'Position', pos .* [1,1,(1+0.1*count),(1+0.1*count)]);
        x = data{1};
        y = data{2};
        clear data;                              
        i = 1;
        j = 1;
        subTitles = cell(0);
        mainTitle = ' ';
        xLab = ' ';
        yLab = ' ';
        xLim = 'auto';
        yLim = 'auto';        
        while i <= length(parameters)
            string = parameters{i};
            if strcmpi(string,'subTitles')
                subTitles = parameters{i+1};                
                i = i + 2;
            elseif strcmpi (string, 'title')
                mainTitle = parameters{i+1};
                i = i + 2;
            elseif strcmpi(string,'xLabel')
                xLab = parameters{i+1};
                i = i + 2;
            elseif strcmpi(string,'yLabel')
                yLab = parameters{i+1};
                i = i + 2;
            elseif strcmpi(string,'xlim')
                xLim = parameters{i+1};
                i = i + 2;
            elseif strcmpi(string,'ylim')
                yLim = parameters{i+1};
                i = i + 2;
            else para{j} = parameters{i};
                i = i + 1;
                j = j + 1;
            end
        end        
        total = size(y,2);        
        if length(subTitles) < total
            temp = cell(total,1);
            start = length(subTitles);            
            temp(1:start) = subTitles;       
            parfor q = start+1:total
                temp{q} = sprintf('sensor: %i',q);
            end
            subTitles = temp;
        end
        if total > count % we have to create more than one subplot image
            first = floor(total / count);
            last = rem(total, count);
            if last ~= 0
                count = count + 1;
            end
            for w = 1:first
                set(0,'currentfigure',figHandle);
                hs = zeros(count-1,1);
                adjustFig(figHandle,para);
                fin = w * (count-1);
                start = fin - count + 2;
                name = strcat(saveName,'(',int2str(start),'-',int2str(fin),')');                
                for q = start:fin
                    set(0,'currentfigure',figHandle);
                    if q >= count
                       hs(q-start+1) = subplot(count-1,1,q-start+1);
                    else
                       hs(q-start+1) = subplot(count-1,1,q);
                    end
                    plot(get(figHandle,'currentaxes'),x,y(:,q));
                    adjustFig(figHandle,{'xticklabel',[],'ytick',[min(yLim) mean(yLim) max(yLim)],...
                        'xlim', xLim,'ylim',yLim,'subtitle',subTitles{q},'xGrid','on'});  
                    xtl=get(gca,'xtick');                  
                end                                                     
                % Reset the bottom subplot to have xticks                
                subplot(count-1,1,count-1);
                adjustFig(figHandle,{'xticklabel',xtl,'xlabel',xLab,'ylabel',yLab});
                % set main title
                axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],...
                    'Box','off','Visible','off','Units','normalized',...
                    'clipping' , 'off'); % create new axes object for title
                text(0.05, 0.98,mainTitle,'HorizontalAlignment', ...
                    'left','VerticalAlignment', 'top',...
                    'Interpreter','Latex','FontSize',hash.get('titleFontSize'));
                % save plot
                savePlot(name);
                % clean up
                delete(hs);
            end                            
            if last~=0
                set(0,'currentfigure',figHandle);
                set(figHandle,'Position',pos .* [1,1,(1+0.1*count),(1+0.1*count)]);
                fin = first * (count-1) + last;
                start = fin - last + 1;
                name = strcat(saveName,'(',int2str(start),'-',int2str(fin),')');                
                hs = zeros(fin-start+1,1);
                for q = start:fin 
                    set(0,'currentfigure',figHandle);
                    hs(q-start+1) = subplot(last,1,q-start+1);                                                      
                    plot(get(figHandle,'currentaxes'),x,y(:,q));                    
                    adjustFig(figHandle,{'xticklabel',[],'ytick',[min(yLim) mean(yLim) max(yLim)],...
                        'xlim', xLim,'ylim',yLim,'subtitle',subTitles{q},'xGrid','on'});              
                    xtl=get(gca,'xtick');
                end                
                % Reset the bottom subplot to have xticks                
                adjustFig(figHandle,{'xticklabel',xtl,'xlabel',xLab,'ylabel',yLab});
                % set main title
                axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],...
                    'Box','off','Visible','off','Units','normalized',...
                    'clipping' , 'off');
                text(0.05, 0.98,mainTitle,'HorizontalAlignment', ...
                    'left','VerticalAlignment', 'top',...
                    'Interpreter','Latex','FontSize',hash.get('titleFontSize'));
                savePlot(name);
                delete(hs);
            end
        else % we must not split subplots 
            set(0,'currentfigure',figHandle);
            set(figHandle,'position',pos .* [1 1 1+0.1*total 1+0.1*total]);
            hs = zeros(total,1);
            if strcmpi('auto',yLim);
                yti = 'auto';
            elseif size(yLim,1) > 1
                yti = 'auto';
                writeOutput(1,'plot:subplot','Can not handle limit row vector or matrix');
                hash = getpref('gui',hash);
            else yti = yLim;
            end            
            for q = 1:total
                set(0,'currentfigure',figHandle);
                hs(q) = subplot(total,1,q);
                plot(get(figHandle,'currentaxes'),x,y(:,q));                              
                adjustFig(figHandle,{'xticklabel',[],'ytick',yti,...
                        'xlim', xLim,'ylim',yLim,'subtitle',subTitles{q},'xGrid','on'});      
                xtl=get(gca,'xtick');  
            end
            % Reset the bottom subplot to have xticks% Reset the bottom subplot to have xticks                
            adjustFig(figHandle,{'xticklabel',xtl,'xlabel',xLab,'ylabel',yLab});
            % set main title
            axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],...
                'Box','off','Visible','off','Units','normalized',...
                'clipping' , 'off');
            text(0.05, 0.98,mainTitle,'HorizontalAlignment', ...
                'left','VerticalAlignment', 'top',...
                'Interpreter','Latex','FontSize',hash.get('titleFontSize'));
            savePlot(saveName);            
            delete(hs);
        end  
        set(figHandle,'Position',pos);
    case 6 % Subplot 3D
        writeOutput(1,'plotMe:subplot3D','3D subplot creation is not implemented');
        hash = getpref('gui','hash');
    case 7 % Textbox  
        set(0,'currentfigure',figHandle);
        % exclude position
        position = parameters{1};
        parameters = parameters(2:length(parameters));
        % generate parameters / arguments         
        h = text('position',position,'string',data);                   
        adjustFig(h,parameters,3);
        hash.put('textBox',h);
        % save as image
        savePlot(saveName);
    case 8 %loglog 2D
        set(0,'currentfigure',figHandle);
        loglog(data{1},data{2});
        adjustFig(figHandle,parameters);        
        % save as image
        if saveFlag
            imageName = savePlot(saveName,outputDir);             
        end
        
end
end