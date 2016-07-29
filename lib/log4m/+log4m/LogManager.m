classdef LogManager < handle
    
    methods (Static)
        
        function l = getLogger(className)
            l = log4m.Logger(className);
        end
        
    end
    
end

