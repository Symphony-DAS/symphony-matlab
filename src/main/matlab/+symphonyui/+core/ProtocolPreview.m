classdef ProtocolPreview < handle
    % A ProtocolPreview manages a ui panel to present a preview of protocol's stimuli.
    %
    % To write a new preview:
    %   1. Subclass ProtocolPreview
    %   2. Implement a constructor method to build the preview ui
    %   3. Implement the update method to update preview when protocol properties change
    
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

