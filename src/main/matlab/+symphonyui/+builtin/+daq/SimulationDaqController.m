classdef SimulationDaqController < symphonyui.core.DaqController
    
    properties
    end
    
    methods
        
        function obj = SimulationDaqController()
            NET.addAssembly(which('Symphony.SimulationDAQController.dll'));
            
            cobj = Symphony.SimulationDAQController.SimulationDAQController();
            obj@symphonyui.core.DaqController(cobj);
        end
        
    end
    
end

