classdef ConfigurationService < handle
    
    events (NotifyAccess = private)
        InitializedRig
        ChangedRigState
    end
    
    properties (Access = private)
        session
        rigDescriptionRepository
        rigStateListener
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
                delete(obj.session.getRig());
            end
            if isempty(description)
                rig = obj.emptyRig;
            else
                rig = symphonyui.core.Rig(description);
            end
            rig.initialize();
            obj.session.setRig(rig);
            obj.rigStateListener = addlistener(rig, 'state', 'PostSet', @(h,d)notify(obj, 'ChangedRigState'));
            notify(obj, 'InitializedRig');
        end
        
        function s = getRigState(obj)
            s = obj.session.getRig().state;
        end
        
        function [tf, msg] = isRigValid(obj)
            [tf, msg] = obj.session.getRig().isValid();
        end
        
    end

end
