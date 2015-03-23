classdef LogManager < handle
    
    methods (Static)
        
        function l = getLogger(className)
            l = symphonyui.infra.Logger(className);
        end
        
    end
    
end

