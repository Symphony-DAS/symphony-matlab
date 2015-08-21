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
        
        function cn = getAvailableRigDescriptions(obj)
            cn = obj.rigDescriptionRepository.getAll();
        end
        
        function initializeRig(obj, description)
            if obj.session.hasRig()
                delete(obj.session.getRig());
                obj.session.rig = [];
            end
            constructor = str2func(description);
            rig = symphonyui.core.Rig(constructor());
            obj.session.rig = rig;
            obj.session.controller.setRig(rig);
            if obj.session.hasProtocol()
                obj.session.protocol.setRig(rig);
            end
            notify(obj, 'InitializedRig');
        end
        
    end

end
