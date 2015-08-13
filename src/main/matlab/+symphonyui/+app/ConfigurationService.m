classdef ConfigurationService < handle
    
    events (NotifyAccess = private)
        InitializedRig
    end
    
    properties (Access = private)
        session
        rigDescriptionRepository
        emptyRig
    end
    
    methods
        
        function obj = ConfigurationService(session, rigDescriptionRepository)
            obj.session = session;
            obj.rigDescriptionRepository = rigDescriptionRepository;
            obj.emptyRig = symphonyui.app.NullRig();
        end
        
        function d = getAvailableRigDescriptions(obj)
            d = obj.rigDescriptionRepository.getAll();
        end
        
        function initializeRig(obj, description)
            if obj.session.hasRig()
                obj.session.getRig().close();
            end
            if isempty(description)
                rig = obj.emptyRig;
            else
                rig = symphonyui.core.Rig(description);
            end
            rig.initialize();
            obj.session.setRig(rig);
            notify(obj, 'InitializedRig');
        end
        
    end

end
