classdef ProtocolPreview < handle
    
    properties (SetAccess = private)
        container
    end
    
    methods
        
        function obj = ProtocolPreview()
            obj.container = uipanel( ...
                'Parent', [], ...
                'BorderType', 'none');
        end
        
    end
    
    methods (Abstract)
        update(obj);
    end
    
end

