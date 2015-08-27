classdef ResponseFigureHandler < symphonyui.core.FigureHandler
    
    properties (Access = private)
        device
        axes
        line
    end
    
    methods
        
        function obj = ResponseFigureHandler(device)
            obj.device = device;
            
            try
                obj.createUi();
            catch x
                obj.close();
                rethrow(x);
            end
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
            xlabel(obj.axes, 'sec');
        end
        
        function handleEpoch(obj, epoch)
            if ~epoch.hasResponse(obj.device)
                return;
            end
            
            response = epoch.getResponse(obj.device);
            [quantities, units] = response.getData();
            x = (1:numel(quantities)) / response.sampleRate.quantityInBaseUnits;
            y = quantities;
            if isempty(obj.line)
                obj.line = line(x, y, 'Parent', obj.axes); %#ok<CPROP>
            else
                set(obj.line, 'XData', x, 'YData', y);
            end
            ylabel(obj.axes, units, 'Interpreter', 'none');
        end
        
        function tf = isequal(obj, other)
            tf = obj.device == other.device;
        end
        
    end
    
end

