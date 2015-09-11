classdef ResponseFigure < symphonyui.core.FigureHandler
    
    properties (Access = private)
        device
        axes
        line
    end
    
    methods
        
        function obj = ResponseFigure(device)
            obj.device = device;
            obj.createUi();
        end
        
        function createUi(obj)
            set(obj.figureHandle, ...
                'Name', [obj.device.name ' Response']);
            
            obj.axes = axes( ...
                'Parent', obj.figureHandle, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize'), ...
                'XTickMode', 'auto'); %#ok<CPROP>
            title(obj.axes, [obj.device.name, ' Response']);
            obj.line = line(0, 0, 'Parent', obj.axes); %#ok<CPROP>
            xlabel(obj.axes, 'sec');
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
            set(obj.line, 'XData', x, 'YData', y);
            ylabel(obj.axes, units, 'Interpreter', 'none');
        end
        
        function tf = isequal(obj, other)
            tf = obj.device == other.device;
        end
        
    end
    
end

