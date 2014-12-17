classdef Controller < handle
    
    properties (SetObservable)
        experiment
        protocol
    end
    
    methods
        
        function run(obj)
            disp('Controller Run');
        end
        
        function pause(obj)
            disp('Controller Pause');
        end
        
        function stop(obj)
            disp('Controller Stop');
        end
        
    end
    
end

