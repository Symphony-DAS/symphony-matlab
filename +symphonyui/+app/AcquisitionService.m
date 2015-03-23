classdef AcquisitionService < symphonyui.util.mixin.Observer
    
    events (NotifyAccess = private)
        OpenedExperiment
        ClosedExperiment
        SelectedRig
        SelectedProtocol
    end
    
    properties (Access = private)
        experimentFactory
        rigRepository
        protocolRepository
    end
    
    properties (Access = private)
        currentExperiment
        currentRig
        currentProtocol
    end
    
    methods
        
        function obj = AcquisitionService(experimentFactory, rigRepository, protocolRepository)
            obj.experimentFactory = experimentFactory;
            
            obj.rigRepository = rigRepository;
            rigs = rigRepository.getAll();
            if isempty(rigs)
                error('At least one rig should exist in the repo');
            end
            
            % Prefer starting with a non-null rig.
            if isa(rigs{1}, 'symphonyui.infra.nulls.NullRig') && numel(rigs) > 1
                obj.currentRig = rigs{2};
            else
                obj.currentRig = rigs{1};
            end
            
            obj.protocolRepository = protocolRepository;
            protocols = protocolRepository.getAll();
            if isempty(protocols)
                error('At least one protocol should exist in the repo');
            end
            
            % Prefer starting with a non-null protocol.
            if isa(protocols{1}, 'symphonyui.infra.nulls.NullProtocol') && numel(protocols) > 1
                obj.currentProtocol = protocols{2};
            else
                obj.currentProtocol = protocols{1};
            end
        end
        
        function close(obj)
            if ~isempty(obj.currentExperiment)
                obj.closeExperiment();
            end
        end
        
        %% Experiment
        
        function createExperiment(obj, name, location, purpose)
            if ~isempty(obj.currentExperiment)
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.create(name, location, purpose);
            experiment.open();
            obj.currentExperiment = experiment;
            notify(obj, 'OpenedExperiment');
        end
        
        function openExperiment(obj, path)
            if ~isempty(obj.currentExperiment)
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.open(path);
            obj.currentExperiment = experiment;
            notify(obj, 'OpenedExperiment');
        end
        
        function closeExperiment(obj)
            if isempty(obj.currentExperiment)
                error('No experiment open');
            end
            obj.currentExperiment.close();
            obj.currentExperiment = [];
            notify(obj, 'ClosedExperiment');
        end
        
        function e = getCurrentExperiment(obj)
            e = obj.currentExperiment;
        end
        
        %% Rig
        
        function i = getAvailableRigIds(obj)
            i = obj.rigRepository.getAllIds();
        end
        
        function selectRig(obj, id)
            obj.currentRig = obj.rigRepository.get(id);
            obj.currentProtocol.setRig(obj.currentRig);
            notify(obj, 'SelectedRig');
        end
        
        function r = getCurrentRig(obj)
            r = obj.currentRig;
        end
        
        %% Protocol
        
        function i = getAvailableProtocolIds(obj)
            i = obj.protocolRepository.getAllIds();
        end
        
        function selectProtocol(obj, id)
            obj.currentProtocol = obj.protocolRepository.get(id);
            obj.currentProtocol.setRig(obj.currentRig);
            notify(obj, 'SelectedProtocol');
        end
        
        function p = getCurrentProtocol(obj)
            p = obj.currentProtocol;
        end
        
        %% Acquisition
        
        function record(obj)
            if ~obj.hasCurrentExperiment
                error('No experiment open');
            end
            obj.currentRig.record(obj.currentProtocol, obj.currentExperiment);
        end
        
        function preview(obj)
            obj.currentRig.preview(obj.currentProtocol);
        end
        
        function pause(obj)
            obj.currentRig.pause();
        end
        
        function stop(obj)
            obj.currentRig.stop();
        end
        
        function [tf, msg] = validate(obj)
            [tf, msg] = obj.currentRig.isValid();
            if tf
                [tf, msg] = obj.currentProtocol.isValid();
            end
        end
        
    end
    
end

