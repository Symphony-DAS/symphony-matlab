classdef AcquisitionService < handle

    events (NotifyAccess = private)
        OpenedExperiment
        ClosedExperiment
        LoadedRigConfiguration
        SelectedProtocol
    end

    properties (Access = private)
        experimentFactory
        rigFactory
        protocolRepository
    end

    properties (Access = private)
        session
    end

    methods

        function obj = AcquisitionService(experimentFactory, rigFactory, protocolRepository)
            obj.experimentFactory = experimentFactory;
            obj.rigFactory = rigFactory;
            obj.protocolRepository = protocolRepository;
            
            rig = rigFactory.create();
            rig.initialize();
            
            obj.session = struct( ...
                'experiment', [], ...
                'rig', rig, ...
                'protocol', symphonyui.app.NullProtocol());
        end

        function delete(obj)
            if ~isempty(obj.getCurrentExperiment())
                obj.closeExperiment();
            end
            obj.getCurrentRig().close();
        end

        %% Experiment

        function createExperiment(obj, name, location, purpose)
            if ~isempty(obj.getCurrentExperiment())
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.create(name, location, purpose);
            experiment.open();
            obj.session.experiment = experiment;
            notify(obj, 'OpenedExperiment');
        end

        function openExperiment(obj, path)
            if ~isempty(obj.getCurrentExperiment())
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.load(path);
            experiment.open();
            obj.session.experiment = experiment;
            notify(obj, 'OpenedExperiment');
        end
        
        function closeExperiment(obj)
            if isempty(obj.getCurrentExperiment())
                error('No experiment open');
            end
            obj.session.experiment.close();
            obj.session.experiment = [];
            notify(obj, 'ClosedExperiment');
        end

        function e = getCurrentExperiment(obj)
            e = obj.session.experiment;
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
            if isempty(obj.getCurrentExperiment())
                error('No experiment open');
            end
            rig = obj.getCurrentRig();
            protocol = obj.getCurrentProtocol();
            experiment = obj.getCurrentExperiment();
            rig.record(protocol, experiment);
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
