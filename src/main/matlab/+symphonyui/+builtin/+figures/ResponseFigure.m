classdef ResponseFigure < symphonyui.core.FigureHandler
    
    properties (SetAccess = private)
        sweepColor
        storedSweepColor
    end
    
    properties (Access = private)
        device
        axesHandle
        sweep
        storedSweep
    end
    
    methods
        
        function obj = ResponseFigure(device, varargin)
            obj@symphonyui.core.FigureHandler(device.name);
            try
                obj.device = device;
                obj.parseVargin(varargin{:});
                obj.createUi();
            catch x
                obj.close();
                rethrow(x);
            end
        end
        
        function parseVargin(obj, varargin)
            ip = inputParser();
            co = get(groot, 'defaultAxesColorOrder');
            ip.addParameter('sweepColor', co(1,:), @(x)ischar(x) || isvector(x));
            ip.addParameter('storedSweepColor', 'r', @(x)ischar(x) || isvector(x));
            ip.parse(varargin{:});

            obj.sweepColor = ip.Results.sweepColor;
            obj.storedSweepColor = ip.Results.storedSweepColor;
        end
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            toolbar = findall(obj.figureHandle, 'Type', 'uitoolbar');
            storeSweepButton = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Store Sweep', ...
                'Separator', 'on', ...
                'ClickedCallback', @obj.onSelectedStoreSweep);
            setIconImage(storeSweepButton, symphonyui.app.App.getResource('icons/sweep_store.png'));
            
            obj.axesHandle = axes( ...
                'Parent', obj.figureHandle, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto');
            xlabel(obj.axesHandle, 'sec');
            
            obj.setTitle([obj.device.name ' Response']);
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
            title(obj.axesHandle, t);
        end
        
        function clear(obj)
            cla(obj.axesHandle);
            obj.sweep = [];
        end
        
        function handleEpoch(obj, epoch)
            if ~epoch.hasResponse(obj.device)
                obj.clear();
                return;
            end
            
            response = epoch.getResponse(obj.device);
            [quantities, units] = response.getData();
            if numel(quantities) > 0
                x = (1:numel(quantities)) / response.sampleRate.quantityInBaseUnits;
                y = quantities;
            else
                x = [];
                y = [];
            end
            if isempty(obj.sweep)
                obj.sweep = line(x, y, 'Parent', obj.axesHandle, 'Color', obj.sweepColor);
            else
                set(obj.sweep, 'XData', x, 'YData', y);
            end
            ylabel(obj.axesHandle, units, 'Interpreter', 'none');
        end
        
        function tf = isequal(obj, other)
            if isempty(obj) || isempty(other) || ~isa(other, class(obj))
                tf = false;
                return;
            end
            tf = obj.device == other.device;
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedStoreSweep(obj, ~, ~)
            if ~isempty(obj.storedSweep)
                delete(obj.storedSweep);
            end
            obj.storedSweep = copyobj(obj.sweep, obj.axesHandle);
            set(obj.storedSweep, ...
                'Color', obj.storedSweepColor, ...
                'HandleVisibility', 'off');
        end
        
    end
        
end

