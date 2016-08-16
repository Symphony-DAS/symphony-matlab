classdef SimulatedNiDaqWithMultiClamp < symphonyui.core.descriptions.RigDescription
    
    methods
        
        function obj = SimulatedNiDaqWithMultiClamp()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            import symphonyui.core.*;
            
            daq = NiSimulationDaqController();
            obj.daqController = daq;
        end
        
    end
    
end

