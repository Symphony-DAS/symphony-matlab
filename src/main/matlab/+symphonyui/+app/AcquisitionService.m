classdef AcquisitionService < handle

    events (NotifyAccess = private)
        SelectedProtocol
        SetProtocolProperties
        ChangedControllerState
        AddedProtocolPreset
        RemovedProtocolPreset
    end

    properties (Access = private)
        log
        session
        classRepository
        protocolPropertyMap
    end

    methods

        function obj = AcquisitionService(session, classRepository)
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.session = session;
            obj.classRepository = classRepository;
            obj.protocolPropertyMap = containers.Map();

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
                className = class(protocol);
            else
                constructor = str2func(className);
                protocol = constructor();
            end
            protocol.setRig(obj.session.rig);
            protocol.setPersistor(obj.session.persistor);
            obj.protocolPropertyMap(class(obj.session.protocol)) =  obj.session.protocol.getProperties();
            try %#ok<TRYNC>
                protocol.setProperties(obj.protocolPropertyMap(className));
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
            obj.session.protocol.setProperty(name, value);
            obj.session.protocol.closeFigures();
            notify(obj, 'SetProtocolProperties');
        end

        function setProtocolProperties(obj, map)
            obj.session.protocol.setProperties(map);
            obj.session.protocol.closeFigures();
            notify(obj, 'SetProtocolProperties');
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

        function resetProtocol(obj)
            constructor = str2func(class(obj.session.protocol));
            protocol = constructor();
            protocol.setRig(obj.session.rig);
            protocol.setPersistor(obj.session.persistor);
            obj.session.protocol.close();
            obj.session.protocol = protocol;
            notify(obj, 'SelectedProtocol');
        end

        function p = getAvailableProtocolPresets(obj)
            presets = obj.session.presets.protocolPresets;
            p = presets.keys;
        end

        function p = getProtocolPreset(obj, name)
            presets = obj.session.presets.protocolPresets;
            if ~presets.isKey(name)
                error([name ' is not an available protocol preset']);
            end
            p = presets(name);
        end

        function applyProtocolPreset(obj, name)
            presets = obj.session.presets.protocolPresets;
            if ~presets.isKey(name)
                error([name ' is not an available protocol preset']);
            end
            preset = presets(name);
            if ~strcmp(preset.protocolId, class(obj.session.protocol))
                obj.selectProtocol(preset.protocolId);
            end
            if ~isequal(preset.propertyMap, obj.session.protocol.getProperties())
                obj.session.protocol.applyPreset(preset);
                obj.session.protocol.closeFigures();
                notify(obj, 'SetProtocolProperties');
            end
        end

        function p = addProtocolPreset(obj, name)
            presets = obj.session.presets.protocolPresets;
            if presets.isKey(name)
                error([name ' is already a protocol preset']);
            end
            p = obj.session.protocol.createPreset(name);
            presets(name) = p;
            obj.session.presets.protocolPresets = presets;
            obj.session.presets.save();
            notify(obj, 'AddedProtocolPreset', symphonyui.app.AppEventData(p));
        end

        function removeProtocolPreset(obj, name)
            presets = obj.session.presets.protocolPresets;
            if ~presets.isKey(name)
                error([name ' is not an available protocol preset']);
            end
            p = presets(name);
            presets.remove(name);
            obj.session.presets.protocolPresets = presets;
            obj.session.presets.save();
            notify(obj, 'RemovedProtocolPreset', symphonyui.app.AppEventData(p));
        end

        function [tf, msg] = isValid(obj)
            [tf, msg] = obj.session.protocol.isValid();
        end

    end

end
