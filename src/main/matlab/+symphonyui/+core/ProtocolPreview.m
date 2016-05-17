classdef ProtocolPreview < handle
    % A ProtocolPreview manages a ui panel to present a preview of protocol's stimuli.
    
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

