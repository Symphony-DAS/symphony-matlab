classdef SimulationDaqController < symphonyui.core.DaqController
    
    properties
        simulationRunner
    end
    
    methods
        
        function obj = SimulationDaqController()
            NET.addAssembly(which('Symphony.SimulationDAQController.dll'));
            
            cobj = Symphony.SimulationDAQController.SimulationDAQController();
            obj@symphonyui.core.DaqController(cobj);
        end
        
        function set.simulationRunner(obj, r)
            obj.cobj.SimulationRunner = r;
        end
        
        function r = get.simulationRunner(obj)
            r = obj.cobj.SimulationRunner;
        end
        
        function addStream(obj, stream)
            obj.tryCore(@()obj.cobj.AddStream(stream.cobj));
        end
        
    end
    
end

