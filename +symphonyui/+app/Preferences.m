classdef Preferences < handle
    
    properties (SetAccess = private)
        epochGroupPreferences
        experimentPreferences
        protocolPreferences
        rigPreferences
    end
    
    methods
        
        function obj = Preferences()
            import symphonyui.preferences.*;
            obj.epochGroupPreferences = EpochGroupPreferences();
            obj.experimentPreferences = ExperimentPreferences();
            obj.protocolPreferences = ProtocolPreferences();
            obj.rigPreferences = RigPreferences();
        end
        
        function setToDefaults(obj)
            obj.epochGroupPreferences.setToDefaults();
            obj.experimentPreferences.setToDefaults();
            obj.protocolPreferences.setToDefaults();
            obj.rigPreferences.setToDefaults();
        end
        
    end
    
    methods (Static)
        
        function obj = getDefault()
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj = symphonyui.app.Preferences();
                localObj.setToDefaults();
            end
            obj = localObj;            
        end
        
    end
    
end

