classdef Sample < symphonyui.core.RigConfiguration
    
    methods
        
        function obj = Sample()
            import symphonyui.builtin.devices.*;
            
            obj.devices{end + 1} = MultiClampDevice();
            obj.devices{end + 1} = GenericDevice();
        end
        
    end
    
end

