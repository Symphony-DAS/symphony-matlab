classdef AppPreference < handle
    
    properties
        experimentPreference
        epochGroupPreference
    end
    
    methods
        
        function obj = AppPreference()
            import SymphonyUI.Preferences.*;
            
            obj.experimentPreference = ExperimentPreference();
            obj.epochGroupPreference = EpochGroupPreference();
        end
        
        function setToDefaults(obj)
            obj.experimentPreference.setToDefaults();
            obj.epochGroupPreference.setToDefaults();
        end
        
    end
    
end

