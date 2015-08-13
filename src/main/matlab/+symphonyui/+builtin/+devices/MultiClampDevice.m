classdef MultiClampDevice < symphonyui.core.Device
    
    properties
    end
    
    methods
        
        function obj = MultiClampDevice()
            
        end
        
        function delete(obj)
            obj.tryCore(@()obj.cobj.Dispose());
        end
        
        function m = getMode(obj)
            
        end
        
    end
    
end

