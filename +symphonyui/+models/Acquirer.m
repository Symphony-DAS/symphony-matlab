classdef Acquirer < handle
    
    properties (SetObservable, SetAccess = private)
        state
    end
    
    methods
        
        function obj = Acquirer()
            obj.state = symphonyui.models.AcquisitionState.STOPPED;
        end
        
        function recordProtocol(obj, protocol, experiment)
            disp('Record');
            disp(protocol);
            obj.state = symphonyui.models.AcquisitionState.RECORDING;
        end
        
        function runProtocol(obj, protocol)
            disp('Run');
            disp(protocol);
            obj.state = symphonyui.models.AcquisitionState.RUNNING;
        end
        
        function pause(obj)
            disp('Pause');
            obj.state = symphonyui.models.AcquisitionState.PAUSING;
            pause(1);
            obj.state = symphonyui.models.AcquisitionState.PAUSED;
        end
        
        function stop(obj)
            disp('Stop');
            obj.state = symphonyui.models.AcquisitionState.STOPPING;
            pause(1);
            obj.state = symphonyui.models.AcquisitionState.STOPPED;
        end
        
    end
    
end

