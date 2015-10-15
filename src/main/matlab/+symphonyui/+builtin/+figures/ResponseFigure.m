classdef ResponseFigure < symphonyui.core.FigureHandler
    
    properties (Access = private)
        device
        axes
        sweep
        storedSweep
    end
    
    methods
        
        function obj = ResponseFigure(device)
            obj@symphonyui.core.FigureHandler(device.name);
            obj.device = device;
            obj.createUi();
        end
        
        function createUi(obj)
            import symphonyui.ui.util.*;
            
            set(obj.figureHandle, ...
                'Name', [obj.device.name ' Response']);
            
            toolbar = findall(obj.figureHandle, 'Type', 'uitoolbar');
            storeSweepButton = uipushtool( ...
                'Parent', toolbar, ...
                'TooltipString', 'Store Sweep', ...
                'Separator', 'on', ...
                'ClickedCallback', @obj.onSelectedStoreSweep);
            setIconImage(storeSweepButton, symphonyui.app.App.getResource('icons/sweep_store.png'));
            
            obj.axes = axes( ...
                'Parent', obj.figureHandle, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto'); %#ok<CPROP>
            title(obj.axes, [obj.device.name, ' Response']);
            xlabel(obj.axes, 'sec');
            obj.sweep = line(0, 0, 'Parent', obj.axes);
        end
        
        function clear(obj)
            cla(obj.axes);
            obj.sweep = line(0, 0, 'Parent', obj.axes);
        end
        
        function handleEpoch(obj, epoch)
            if ~epoch.hasResponse(obj.device)
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
            ylabel(obj.axes, units, 'Interpreter', 'none');
        end
        
        function tf = isequal(obj, other)
            tf = obj.device == other.device;
        end
        
    end
    
    methods (Access = private)
        
        function onSelectedStoreSweep(obj, ~, ~)
            if ~isempty(obj.storedSweep)
                delete(obj.storedSweep);
            end
            obj.storedSweep = copyobj(obj.sweep, obj.axes);
            set(obj.storedSweep, ...
                'Color', 'r', ...
                'HandleVisibility', 'off');
        end
        
    end
        
end

