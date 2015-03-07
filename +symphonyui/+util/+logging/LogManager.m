classdef LogManager < handle
    
    methods (Static)
        
        function l = getLogger(className)
            l = symphonyui.util.logging.Logger(className);
        end
        
    end
    
end

