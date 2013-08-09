function varargout = adjustFig(fig,properties,varargin)
% This functions adjusts the layout of our figure and axes
% fig = handle of figure that should be adjusted
% properties =
% {'Title','cN','xAxisLabel','chord','PropertyName','PropertyValue',...}
% remark: set FontSizes prior to all other settings

skip = 0;
toTU = 0;
interpreter = 'none';
fontUnit = 'points';
labelFontSize = 16;
titleFontSize = 20;
legendFontSize = 18;
fontSize = 32;
fontName = 'Helvetica';
% generate allowed properties
figProperties = {'fontName';'name';'paperType';'paperSize';'paperPositionMode';...
    'paperPosition'; 'paperUnits';'figPosition'};

axProperties = {'interpreter';'legendFontSize';'fontUnits';...
    'labelFontSize';'fontSize';'titleFontSize';...    
    'title';'xlabel';'ylabel';'zlabel';'legend';'xlim';...
    'ylim';'zlim';'xtick';'ytick';'ztick';...
    'outerPosition';...
    'viewQuat';'yDir';'xTick';'yTick';'zTick';'xdir';...
    'yAxisLocation';'xTickMode';'yTickMode';'zTickMode';'Ygrid';'xGrid';'zGrid';...
    'yScale';'xScale';'zScale';'xDir';'zDir';'box';'subtitle';...
    'visible';'clipping';'units';'position';'xtickLabel';'yticklabel';'zticklabel'};
linProperties = {'MarkerFaceColor';'MarkerEdgeColor';'MarkerSize';'Marker';'lineStyle';'color';'lineWidth';'lineWidthAll'};
textProperties = {};

% get axis handle
if nargin == 2
    ax = get(fig,'currentAxes');
    lin = findobj('Type','line');
else 
    if isnumeric(varargin{1})
        if varargin{1}==3
            for i = 1:length(names)
                set(fig,names{i},values{i});
            end        
            skip = 1;
        else
            ax = fig;
            lin = findobj('Type','line');
        end
    elseif strcmpi(varargin{1},'toTU')
        skip = 1;
        toTU = 1;
        ax = get(fig,'currentAxes');
        lin = findobj('Type','line');
    else
        ax = fig;
        lin = findobj('Type','line');
    end;
end
% get properties
if ~skip
    set(ax,'FontName',fontName);
    set(legend,'FontName',fontName);
    
    [names values] = parseArguments([figProperties;axProperties;linProperties;textProperties],properties);
    if ~iscell(names)
        warning('adjustFig:parseArguments',names);    
        return
    end
    axProVal = {};
    figProVal = {};
    linProVal = {};    
    temp = names;
    temp2 = values;
    done = 0;
    for j = 1:length(axProperties)
        names = temp;
        values = temp2;
        temp2 = {};
        temp = {};
        for i = 1:length(names)
            name = names{i};
            if strcmpi(name,axProperties{j})
                axProVal = [axProVal; name ,values(i)];
                done = done + 1;
            else
                temp2 = [temp2 values(i)];
                temp = [temp name];
            end
        end
    end
    for k = 1:length(figProperties)
        names = temp;
        values = temp2;
        temp2 = {};
        temp = {};
        for i = 1:length(names)
            name = names{i};
            if strcmpi(name,figProperties{k})
                figProVal = [figProVal; name ,values(i)];
                done = done + 1;            
            else
                temp2 = [temp2 values(i)];
                temp = [temp name];
            end        
        end
    end
    for m = 1:length(linProperties)
        names = temp;
        values = temp2;
        temp2 = {};
        temp = {};
        for i = 1:length(names)
            name = names{i};
            if strcmpi(name,linProperties{m})
                linProVal = [linProVal;name,values(i)];
                done = done + 1;
            else
                temp2 = [temp2 values(i)];
                temp = [temp name];
            end
        end
    end
    if ~isempty(temp)
        warning('adjustFig','Some properties were not found!');
    end    
    for i = 1:size(figProVal,1)
        prop = figProVal{i,1};
        if strcmpi(prop,'figPosition');
            set(fig,'Position',figProVal{i,2});    
        elseif strcmpi(prop,'Interpreter');
            interpreter = latex;
        elseif strcmpi(prop,'FontName')
            set(ax,'FontName',figProVal{i,2});
            set(legend,'FontName',figProVal{i,2});
        end
    end
    for i = 1:size(axProVal,1)
        prop = axProVal{i,1};
        if strcmpi(prop,'xlabel')
            xlabel(axProVal{i,2},'Interpreter',interpreter,'fontSize',labelFontSize,'fontUnits',fontUnit);
        elseif strcmpi(prop,'yLabel')
            ylabel(axProVal{i,2},'Interpreter',interpreter,'fontSize',labelFontSize,'fontUnits',fontUnit);
        elseif strcmpi(prop,'zLabel')
            zlabel(axProVal{i,2},'Interpreter',interpreter,'fontSize',labelFontSize,'fontUnits',fontUnit);
        elseif strcmpi(prop,'legend')        
            legend(axProVal{i,2},'Interpreter',interpreter,'Location','EastOutside','fontSize',legendFontSize,'fontUnits',fontUnit);
        elseif strcmpi(prop,'viewQuat')
            view(axProVal{i,2});
        elseif strcmpi(prop,'title')
            title(axProVal{i,2},'Interpreter',interpreter,'fontSize',titleFontSize,'fontUnits',fontUnit);
        elseif strcmpi(prop,'xlim')
            if isnumeric(axProVal{i,2})
                if any(isnan(axProVal{i,2})) || axProVal{i,2}(1) == axProVal{i,2}(2)
                    limit = 'auto';                
                elseif axProVal{i,2}(1) > axProVal{i,2}(2)
                    limit(1,1) = axProVal{i,2}(2);
                    limit(1,2) = axProVal{i,2}(1);
                else
                    limit = axProVal{i,2};
                end
            else
               limit = axProVal{i,2};
            end
            xlim(limit);
        elseif strcmpi(prop,'ylim')        
            if isnumeric(axProVal{i,2})
                if any(isnan(axProVal{i,2})) || axProVal{i,2}(1) == axProVal{i,2}(2) 
                    limit = 'auto';
                elseif axProVal{i,2}(1) > axProVal{i,2}(2)
                    limit(1,1) = axProVal{i,2}(2);
                    limit(1,2) = axProVal{i,2}(1);
                else
                    limit = axProVal{i,2};
                end
            else
               limit = axProVal{i,2};
            end
            ylim(limit);       
        elseif strcmpi(prop,'zlim')        
            if isnumeric(axProVal{i,2})
                if any(isnan(axProVal{i,2})) || axProVal{i,2}(1) == axProVal{i,2}(2)
                    limit = 'auto';                
                elseif axProVal{i,2}(1) > axProVal{i,2}(2)
                    limit(1,1) = axProVal{i,2}(2);
                    limit(1,2) = axProVal{i,2}(1);
                else
                    limit = axProVal{i,2};
                end
            else
               limit = axProVal{i,2};
            end
            zlim(limit);
        elseif strcmpi(prop,'ytick')
            if isnumeric(axProVal{i,2}) && ~any(isnan(axProVal{i,2}))
                set(ax,prop,axProVal{i,2},'fontSize',fontSize);
            else warning('adjustFig:yTick','Unrecognized ytick');
            end
        elseif strcmpi(prop,'xtick')
            set(ax,prop,axProVal{i,2},'fontSize',fontSize);
        elseif strcmpi(prop,'subtitle')
            title(axProVal{i,2},'Interpreter',interpreter,'fontSize',labelFontSize,'fontUnits',fontUnit);
        elseif strcmpi(prop,'fontSize')
            fontSize = axProVal{i,2};
            set(ax,'fontSize',fontSize);
        elseif strcmpi(prop,'labelFontSize')
            labelFontSize = axProVal{i,2};
        elseif strcmpi(prop,'titleFontSize')
            titleFontSize = axProVal{i,2};
        elseif strcmpi(prop,'legendFontSize')
            legendFontSize = axProVal{i,2};
        elseif strcmpi(prop,'interpreter')
            interpreter = axProVal{i,2};
        elseif strcmpi(prop,'fontUnits')
            fontUnit = axProVal{i,2};
        else % all other values can directly be set over ax
            set(ax,prop,axProVal{i,2});
        end
    end
    for i = 1:size(linProVal,1)        
        prop = linProVal{i,1};
        if strcmpi(prop,'lineWidthAll')
            set(lin,'lineWidth',linProVal{i,2});
        else
            m = 1;
            while m <= length(lin)
                try
                    set(lin(m),prop,linProVal{i,2});%only the least line
                    m = length(lin) + 1;
                catch exception
                    warning('adjustFig:linProp',getReport(exception));
                    m = m + 1;
                end        
            end
        end
        
    end
    varargout{1} = fig;
    varargout{2} = ax;
    varargout{3} = lin;
else
    varargout{1} = {};
    varargout{2} = {};
    varargout{3} = {};
end
if toTU
    % set Interpreter to Latex and set Font to Stafford for everything    
    set(ax,'FontName','Stafford');  
    
end
end