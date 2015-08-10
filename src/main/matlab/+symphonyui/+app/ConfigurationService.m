classdef ConfigurationService < handle
    
    events (NotifyAccess = private)
        InitializedRig
    end
    
    properties (Access = private)
        sessionData
        rigDescriptionRepository
    end
    
    methods
        
        function obj = ConfigurationService(sessionData, rigDescriptionRepository)
            obj.sessionData = sessionData;
            obj.rigDescriptionRepository = rigDescriptionRepository;
        end
        
        function d = getAvailableRigDescriptions(obj)
            d = obj.rigDescriptionRepository.getAll();
        end
        
        function initializeRig(obj, description)
            rig = symphonyui.core.Rig(description);
            rig.initialize();
            obj.sessionData.rig = rig;
            notify(obj, 'InitializedRig');
        end
        
    end
    
    methods (Access = private)
        
        function r = getSessionRig(obj)
            if ~obj.hasSessionRig()
                error('No session rig');
            end
            r = obj.sessionData.rig;
        end
        
        function tf = hasSessionRig(obj)
            tf = ~isempty(obj.sessionData.rig);
        end
        
    end

end
