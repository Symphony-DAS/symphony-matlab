classdef AcquisitionService < handle

    events (NotifyAccess = private)
        SelectedProtocol
        SetProtocolProperty
        ChangedControllerState
        AddedProtocolPreset
        RemovedProtocolPreset
    end

    properties (Access = private)
        log
        session
        classRepository
        presetMap
    end

    methods

        function obj = AcquisitionService(session, classRepository)
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.session = session;
            obj.classRepository = classRepository;
            obj.presetMap = containers.Map();

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
            if isempty(className)
                protocol = symphonyui.app.Session.NULL_PROTOCOL;
            else
                constructor = str2func(className);
                protocol = constructor();
            end
            protocol.setRig(obj.session.rig);
            protocol.setPersistor(obj.session.persistor);
            try
                preset = obj.session.protocol.createPreset('');
                obj.presetMap(preset.protocolId) = preset;
            catch x
                obj.log.debug(x.message, x);
            end
            try
                if obj.presetMap.isKey(className)
                    protocol.applyPreset(obj.presetMap(className));
                end
            catch x
                obj.log.debug(x.message, x);
            end
            obj.session.protocol.close();
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
            obj.session.protocol.closeFigures();
            notify(obj, 'SetProtocolProperty');
        end

        function p = getProtocolPreview(obj, panel)
            p = obj.session.protocol.getPreview(panel);
        end

        function viewOnly(obj)
            if obj.session.controller.state.isViewingPaused()
                obj.session.controller.resume();
                return;
            end
            obj.session.controller.runProtocol(obj.session.protocol, []);
        end

        function record(obj)
            if obj.session.controller.state.isRecordingPaused()
                obj.session.controller.resume();
                return;
            end
            obj.session.controller.runProtocol(obj.session.protocol, obj.session.getPersistor());
        end

        function requestPause(obj)
            obj.session.controller.requestPause();
        end

        function requestStop(obj)
            obj.session.controller.requestStop();
        end

        function s = getControllerState(obj)
            s = obj.session.controller.state;
        end
        
        function p = getAvailableProtocolPresets(obj)
            p = {'one', 'two', 'three'};
        end
        
        function p = getProtocolPreset(obj, name)
            switch name
                case 'one'
                    p = symphonyui.core.ProtocolPreset('one', 'edu.washington.rieke.protocols.Pulse', containers.Map());
                case 'two'
                    p = symphonyui.core.ProtocolPreset('two', 'edu.washington.rieke.protocols.PulseFamily', containers.Map());
                case 'three'
                    p = symphonyui.core.ProtocolPreset('three', 'edu.washington.rieke.protocols.SealAndLeak', containers.Map());
                otherwise
                    error('Unknown');
            end
        end
        
        function p = addProtocolPreset(obj, name)
            p = [];
            notify(obj, 'AddedProtocolPreset');
        end
        
        function removeProtocolPreset(obj, name)
            
            notify(obj, 'RemovedProtocolPreset');
        end

        function [tf, msg] = isValid(obj)
            [tf, msg] = obj.session.protocol.isValid();
        end

    end

end
