classdef AcquisitionService < handle

    events (NotifyAccess = private)
        OpenedFile
        ClosedFile
        LoadedRigConfiguration
        SelectedProtocol
    end

    properties (Access = private)
        persistorFactory
        rigFactory
        protocolRepository
    end

    properties (Access = private)
        session
    end

    methods

        function obj = AcquisitionService(persistorFactory, rigFactory, protocolRepository)
            obj.persistorFactory = persistorFactory;
            obj.rigFactory = rigFactory;
            obj.protocolRepository = protocolRepository;
            
            rig = rigFactory.create();
            rig.initialize();
            
            obj.session = struct( ...
                'persistor', [], ...
                'rig', rig, ...
                'protocol', symphonyui.app.NullProtocol());
        end

        function delete(obj)
            if ~isempty(obj.getCurrentPersistor())
                obj.closeFile();
            end
            obj.getCurrentRig().close();
        end

        %% Persistor

        function createFile(obj, name, location)
            if ~isempty(obj.getCurrentPersistor())
                error('A file is already open');
            end
            persistor = obj.persistorFactory.create(name, location);
            obj.session.persistor = persistor;
            notify(obj, 'OpenedFile');
        end

        function openFile(obj, path)
            if ~isempty(obj.getCurrentPersistor())
                error('A file is already open');
            end
            persistor = obj.persistorFactory.load(path);
            obj.session.persistor = persistor;
            notify(obj, 'OpenedFile');
        end
        
        function closeFile(obj)
            if isempty(obj.getCurrentPersistor())
                error('No file open');
            end
            obj.session.persistor.close();
            obj.session.persistor = [];
            notify(obj, 'ClosedFile');
        end

        function e = getCurrentPersistor(obj)
            e = obj.session.persistor;
        end

        %% Rig
        
        function loadRigConfiguration(obj, path)
            obj.getCurrentRig().close();
            
            rig = obj.rigFactory.load(path);
            rig.initialize();
            
            obj.session.rig = rig;
            obj.session.protocol.setRig(rig);
            
            notify(obj, 'LoadedRigConfiguration');
        end
        
        function saveRigConfiguration(obj, path)
            disp(['Save to: ' path]);
        end
        
        function r = getCurrentRig(obj)
            r = obj.session.rig;
        end
        
        %% Protocol

        function i = getAvailableProtocolIds(obj)
            i = [{'(None)'}, obj.protocolRepository.getAllIds()];
        end

        function selectProtocol(obj, id)
            if strcmp(id, '(None)')
                protocol = symphonyui.app.NullProtocol();
            else
                protocol = obj.protocolRepository.get(id);
            end
            obj.session.protocol = protocol;
            obj.session.protocol.setRig(obj.getCurrentRig());
            notify(obj, 'SelectedProtocol');
        end
        
        function p = getCurrentProtocol(obj)
            p = obj.session.protocol;
        end
        
        function i = getCurrentProtocolId(obj)
            protocol = obj.session.protocol;
            if isa(protocol, 'symphonyui.app.NullProtocol')
                i = '(None)';
                return;
            end
            i = obj.protocolRepository.getId(protocol);
        end

        %% Acquisition

        function record(obj)
            if isempty(obj.getCurrentPersistor())
                error('No persistor open');
            end
            rig = obj.getCurrentRig();
            protocol = obj.getCurrentProtocol();
            persistor = obj.getCurrentPersistor();
            rig.record(protocol, persistor);
        end

        function preview(obj)
            rig = obj.getCurrentRig();
            protocol = obj.getCurrentProtocol();
            rig.preview(protocol);
        end

        function pause(obj)
            rig = obj.getCurrentRig();
            rig.pause();
        end

        function stop(obj)
            rig = obj.getCurrentRig();
            rig.stop();
        end

        function [tf, msg] = validate(obj)
            rig = obj.getCurrentRig();
            protocol = obj.getCurrentProtocol();
            [tf, msg] = rig.isValid();
            if tf
                [tf, msg] = protocol.isValid();
            end
        end

    end

end
