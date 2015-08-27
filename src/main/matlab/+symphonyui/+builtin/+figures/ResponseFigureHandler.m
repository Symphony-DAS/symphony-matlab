classdef ResponseFigureHandler < symphonyui.core.FigureHandler
    
    properties (Access = private)
        device
        axes
    end
    
    methods
        
        function obj = ResponseFigureHandler(device)
            obj.device = device;
            
            obj.createUi();
        end
        
        function createUi(obj)
            set(obj.figureHandle, ...
                'Name', [obj.device.name ' response']);
            
            obj.axes = axes( ...
                'Parent', obj.figureHandle, ...
                'FontName', get(obj.figureHandle, 'DefaultUicontrolFontName'), ...
                'FontSize', get(obj.figureHandle, 'DefaultUicontrolFontSize')); %#ok<CPROP>
        end
        
        function handleEpoch(obj, epoch)
            disp('handle');
        end
        
        function tf = isequal(obj, other)
            tf = obj.device == other.device;
        end
        
    end
    
end

