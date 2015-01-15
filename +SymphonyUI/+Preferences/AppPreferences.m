classdef AppPreferences < handle
    
    properties
        experimentPreferences
        epochGroupPreferences
    end
    
    methods
        
        function obj = AppPreferences()
            import SymphonyUI.Preferences.*;
            
            obj.experimentPreferences = ExperimentPreferences();
            obj.epochGroupPreferences = EpochGroupPreferences();
        end
        
        function setToDefaults(obj)
            obj.experimentPreferences.setToDefaults();
            obj.epochGroupPreferences.setToDefaults();
        end
        
    end
    
end

