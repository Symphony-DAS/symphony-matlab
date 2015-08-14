classdef ControllerState
    
    enumeration
        STOPPED
        STOPPING
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
                case ControllerState.VIEWING
                    c = 'Viewing...';
                case ControllerState.RECORDING
                    c = 'Recording...';
                otherwise
                    c = 'Unknown';
            end
        end
        
    end
    
end

