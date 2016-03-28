classdef ConfigurationService < handle

    events (NotifyAccess = private)
        InitializedRig
    end

    properties (Access = private)
        session
        classRepository
    end

    methods

        function obj = ConfigurationService(session, classRepository)
            obj.session = session;
            obj.classRepository = classRepository;
        end

        function cn = getAvailableRigDescriptions(obj)
            cn = obj.classRepository.get('symphonyui.core.descriptions.RigDescription');
        end

        function initializeRig(obj, description)
            if ~isempty(description) && ~any(strcmp(description, obj.getAvailableRigDescriptions()))
                error([description ' is not an available rig description']);
            end
            obj.session.rig.close();
            if isempty(description)
                rig = symphonyui.app.Session.NULL_RIG;
            else
                constructor = str2func(description);
                rig = symphonyui.core.Rig(constructor());
            end
            obj.session.controller.setRig(rig);
            obj.session.rig = rig;
            notify(obj, 'InitializedRig');
        end

        function d = getDevice(obj, name)
            d = obj.session.rig.getDevice(name);
        end

        function d = getDevices(obj, name)
            if nargin < 2
                name = '.';
            end
            d = obj.session.rig.getDevices(name);
        end

        function d = getOutputDevices(obj)
            d = obj.session.rig.getOutputDevices();
        end

        function d = getInputDevices(obj)
            d = obj.session.rig.getInputDevices();
        end
        
        function o = getOptions(obj)
            o = obj.session.options;
        end

    end

end
