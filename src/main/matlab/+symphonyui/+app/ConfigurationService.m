classdef ConfigurationService < handle
    
    events (NotifyAccess = private)
        InitializedRig
    end
    
    properties (Access = private)
        session
        rigDescriptionRepository
    end
    
    methods
        
        function obj = ConfigurationService(session, rigDescriptionRepository)
            obj.session = session;
            obj.rigDescriptionRepository = rigDescriptionRepository;
        end
        
        function d = getAvailableRigDescriptions(obj)
            d = obj.rigDescriptionRepository.getAll();
        end
        
        function initializeRig(obj, description)
            if obj.session.hasRig()
                obj.session.getRig().close();
            end
            rig = symphonyui.core.Rig(description);
            rig.initialize();
            obj.session.rig = rig;
            obj.session.protocol.setRig(rig);
            obj.session.controller.setRig(rig);
            notify(obj, 'InitializedRig');
        end
        
    end

end
