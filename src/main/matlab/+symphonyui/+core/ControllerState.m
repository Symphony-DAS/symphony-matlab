classdef ControllerState
    
    enumeration
        STOPPED
        STOPPING
        PAUSING
        VIEWING
        VIEWING_PAUSED
        RECORDING
        RECORDING_PAUSED
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
                case ControllerState.PAUSING
                    c = 'Pausing...';
                case ControllerState.VIEWING_PAUSED
                    c = 'Viewing Paused';
                case ControllerState.RECORDING
                    c = 'Recording...';
                case ControllerState.RECORDING_PAUSED
                    c = 'Recording Paused';
                otherwise
                    c = 'Unknown';
            end
        end
        
        function tf = isRunning(obj)
            import symphonyui.core.ControllerState;
            tf = obj == ControllerState.VIEWING || obj == ControllerState.RECORDING;
        end
        
        function tf = isPausing(obj)
            import symphonyui.core.ControllerState;
            tf = obj == ControllerState.PAUSING;
        end
        
        function tf = isPaused(obj)
            import symphonyui.core.ControllerState;
            tf = obj == ControllerState.VIEWING_PAUSED || obj == ControllerState.RECORDING_PAUSED;
        end
        
        function tf = isViewingPaused(obj)
            import symphonyui.core.ControllerState;
            tf = obj == ControllerState.VIEWING_PAUSED;
        end
        
        function tf = isRecordingPaused(obj)
            import symphonyui.core.ControllerState;
            tf = obj == ControllerState.RECORDING_PAUSED;
        end
        
        function tf = isStopping(obj)
            import symphonyui.core.ControllerState;
            tf = obj == ControllerState.STOPPING;
        end
        
        function tf = isStopped(obj)
            import symphonyui.core.ControllerState;
            tf = obj == ControllerState.STOPPED;
        end
        
    end
    
end

