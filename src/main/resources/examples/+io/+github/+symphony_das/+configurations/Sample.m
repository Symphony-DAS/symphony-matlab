classdef Sample < symphonyui.core.RigConfiguration
    
    methods
        
        function obj = Sample()
            import symphonyui.builtin.devices.*;
            
            obj.addDevice(MultiClampDevice());
            obj.addDevice(GenericDevice());
        end
        
    end
    
end

