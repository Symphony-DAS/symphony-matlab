classdef SingleAmp < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = SingleAmp()
            import symphonyui.builtin.devices.*;
            
            obj.daqController = symphonyui.builtin.daq.HekaDaqController();
            
            obj.devices = { ...
                MultiClampDevice(), ...
                GenericDevice(), ...
                GenericDevice(), ...
            };
        end
        
    end
    
end

