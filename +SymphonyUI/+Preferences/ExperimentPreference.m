classdef ExperimentPreference < handle
    
    properties (SetObservable)
        defaultName = ''
        defaultLocation = ''
        defaultPurpose = ''
    end
    
    methods
        
        function setToDefaults(obj)
            obj.defaultName = @()datestr(now, 'yyyy-mm-dd');
            obj.defaultLocation = @pwd;
        end
        
        % TODO: Create setters.
        
    end
    
end

