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
        
        function set.simulationRunner(obj, simulationFcn)
            function cin = runner(obj, fcn, cout, cstep)
                out = obj.mapFromKeyValueEnumerable(cout, @symphonyui.core.OutputData, @(k)k.Name);
                step = obj.durationFromTimeSpan(cstep);
                
                in = fcn(obj, out, step);
                
                cin = NET.createGeneric('System.Collections.Generic.Dictionary', ...
                    {'Symphony.Core.IDAQInputStream', 'Symphony.Core.IInputData'});
                keys = in.keys;
                for i = 1:numel(keys)
                    k = keys{i};
                    cin.Add(obj.getStream(k).cobj, in(k).cobj);
                end
            end
            obj.cobj.SimulationRunner = @(cout, cstep)runner(obj, simulationFcn, cout, cstep);
            obj.simulationRunner = simulationFcn;
        end
        
        function addStream(obj, stream)
            obj.tryCore(@()obj.cobj.AddStream(stream.cobj));
        end
        
    end
    
end

