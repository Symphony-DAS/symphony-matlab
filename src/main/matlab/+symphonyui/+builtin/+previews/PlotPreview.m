classdef PlotPreview < symphonyui.core.ProtocolPreview
    
    properties (Access = private)
        axes
    end
    
    methods
        
        function obj = PlotPreview()
            obj.createUi();
        end
        
        function createUi(obj)
            obj.axes = axes( ...
                'Parent', obj.container, ...
                'XTickMode', 'auto'); %#ok<CPROP>
        end
        
        function update(obj)
            
        end
        
    end
    
end

