classdef NiDaqWithMultiClamp < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = NiDaqWithMultiClamp()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = NiDaqController();
            obj.daqController = daq;
        end
        
    end
    
end

