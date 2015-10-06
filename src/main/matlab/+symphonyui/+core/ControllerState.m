classdef ControllerState
    
    enumeration
        STOPPED
        STOPPING
        PAUSED
        PAUSING
        VIEWING
        RECORDING
    end
    
    methods
        
        function c = char(obj)
            import symphonyui.core.ControllerState;
            
            switch obj
                case ControllerState.STOPPED
                    c = 'Stopped';
                case ControllerState.STOPPING
                    c = 'Stopping...';
                case ControllerState.PAUSED
                    c = 'Paused';
                case ControllerState.PAUSING
                    c = 'Pausing...';
                case ControllerState.VIEWING
                    c = 'Viewing...';
                case ControllerState.RECORDING
                    c = 'Recording...';
                otherwise
                    c = 'Unknown';
            end
        end
        
        function tf = isViewingOrRecording(obj)
            import symphonyui.core.ControllerState;
            tf = obj == ControllerState.VIEWING || obj == ControllerState.RECORDING;
        end
        
    end
    
end

