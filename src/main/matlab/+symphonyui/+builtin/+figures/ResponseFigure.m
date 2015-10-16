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
                delete(obj.figureHandle);
                rethrow(x);
            end
        end
        
        function parseVargin(obj, varargin)
            ip = inputParser();
            ip.addParameter('sweepColor', 'b', @(x)ischar(x) || isvector(x));
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
            obj.sweep = line(0, 0, 'Parent', obj.axesHandle);
            
            obj.setTitle([obj.device.name ' Response']);
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
            title(obj.axesHandle, t);
        end
        
        function clear(obj)
            cla(obj.axesHandle);
            obj.sweep = line(0, 0, 'Parent', obj.axesHandle);
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
            set(obj.sweep, 'XData', x, 'YData', y);
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
                'Color', 'r', ...
                'HandleVisibility', 'off');
        end
        
    end
        
end

