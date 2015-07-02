classdef SingleAmp < symphonyui.core.Rig
    
    methods
        
        function configure(obj)
            import symphonyui.builtin.devices.*;
            
            obj.addDevice(GenericDevice('LED'));
            obj.addDevice(MultiClampDevice('Amp'));
        end
        
    end
    
end

