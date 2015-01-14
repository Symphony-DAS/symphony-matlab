classdef AppPreference < handle
    
    properties
        epochGroupPreference
    end
    
    methods
        
        function obj = AppPreference()
            import SymphonyUI.Preferences.*;
            
            obj.epochGroupPreference = EpochGroupPreference();
        end
        
        function setToDefaults(obj)
            obj.epochGroupPreference.setToDefaults();
        end
        
    end
    
end

