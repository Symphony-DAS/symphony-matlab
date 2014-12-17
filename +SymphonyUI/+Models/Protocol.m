classdef Protocol < handle
    
    properties (Constant)
        name
    end
    
    properties (SetObservable)
        state
    end
    
    methods
        
        function obj = Protocol()
            obj.state = SymphonyUI.Models.ProtocolState.STOPPED;
        end
        
        function run()
            obj.state = SymphonyUI.Models.ProtocolState.RUNNING;
        end
        
    end
    
end

