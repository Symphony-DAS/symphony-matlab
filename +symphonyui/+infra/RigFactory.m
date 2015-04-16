classdef RigFactory < handle
    
    methods
        
        function r = load(obj, path)
            r = io.github.symphony_das.rigs.SingleAmp();
        end
        
    end
    
end

