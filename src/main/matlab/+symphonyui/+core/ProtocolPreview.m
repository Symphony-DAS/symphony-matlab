classdef ProtocolPreview < handle
    
    properties (Access = protected)
        panel
    end
    
    methods
        
        function obj = ProtocolPreview(panel)
            obj.panel = panel;
        end
        
    end
    
    methods (Abstract)
        update(obj)
    end        
    
end

