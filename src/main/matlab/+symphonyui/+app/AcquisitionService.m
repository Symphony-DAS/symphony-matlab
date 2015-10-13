classdef AcquisitionService < handle

    events (NotifyAccess = private)
        SelectedProtocol
        SetProtocolProperty
        ChangedControllerState
    end

    properties (Access = private)
        session
        classRepository
    end

    methods

        function obj = AcquisitionService(session, classRepository)
            obj.session = session;
            obj.classRepository = classRepository;

            addlistener(obj.session, 'rig', 'PostSet', @(h,d)obj.selectProtocol(obj.getSelectedProtocol()));
            addlistener(obj.session, 'persistor', 'PostSet', @(h,d)obj.selectProtocol(obj.getSelectedProtocol()));
            addlistener(obj.session.controller, 'state', 'PostSet', @(h,d)notify(obj, 'ChangedControllerState'));
        end

        function cn = getAvailableProtocols(obj)
            cn = obj.classRepository.get('symphonyui.core.Protocol');
        end

        function selectProtocol(obj, className)
            if ~isempty(className) && ~any(strcmp(className, obj.getAvailableProtocols()))
                error([className ' is not an available protocol']);
            end
            obj.session.protocol.closeFigures();
            if isempty(className)
                protocol = symphonyui.app.Session.NULL_PROTOCOL;
            else
                constructor = str2func(className);
                protocol = constructor();
            end
            protocol.setRig(obj.session.rig);
            protocol.setPersistor(obj.session.persistor);
            obj.session.protocol = protocol;
            notify(obj, 'SelectedProtocol');
        end

        function cn = getSelectedProtocol(obj)
            if obj.session.protocol == symphonyui.app.Session.NULL_PROTOCOL
                cn = [];
                return;
            end
            cn = class(obj.session.protocol);
        end

        function d = getProtocolPropertyDescriptors(obj)
            d = obj.session.protocol.getPropertyDescriptors();
        end

        function setProtocolProperty(obj, name, value)
            obj.session.protocol.(name) = value;
            notify(obj, 'SetProtocolProperty');
        end

        function p = getProtocolPreview(obj, panel)
            p = obj.session.protocol.getPreview(panel);
        end

        function viewOnly(obj)
            if obj.session.controller.state.isViewingPaused()
                obj.session.controller.resume();
            else
                obj.session.protocol.closeFigures();
                obj.session.controller.runProtocol(obj.session.protocol, []);
            end
        end

        function record(obj)
            if obj.session.controller.state.isRecordingPaused()
                obj.session.controller.resume();
            else
                obj.session.protocol.closeFigures();
                obj.session.controller.runProtocol(obj.session.protocol, obj.session.getPersistor());
            end
        end
        
        function pause(obj)
            obj.session.controller.requestPause();
        end

        function stop(obj)
            obj.session.controller.requestStop();
        end

        function s = getControllerState(obj)
            s = obj.session.controller.state;
        end

        function [tf, msg] = isValid(obj)
            [tf, msg] = obj.session.protocol.isValid();
        end

    end

end
