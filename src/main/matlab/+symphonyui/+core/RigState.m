classdef RigState
    
    enumeration
        STOPPED
        STOPPING
        VIEWING
        RECORDING
    end
    
    methods
        
        function c = char(obj)
            import symphonyui.core.RigState;
            
            switch obj
                case RigState.STOPPED
                    c = 'Stopped';
                case RigState.STOPPING
                    c = 'Stopping...';
                case RigState.VIEWING
                    c = 'Viewing...';
                case RigState.RECORDING
                    c = 'Recording...';
                otherwise
                    c = 'Unknown';
            end
        end
        
    end
    
end

