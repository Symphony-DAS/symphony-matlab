classdef HekaMultiClampStage < io.github.symphony_das.rigs.HekaMultiClamp
    
    methods
        
        function obj = HekaMultiClampStage()
            import symphonyui.builtin.daqs.*;
            import symphonyui.builtin.devices.*;
            
            stage = StageDevice();
            
            obj.devices = [obj.devices {stage}];
        end
        
    end
    
end

