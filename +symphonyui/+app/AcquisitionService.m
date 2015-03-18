classdef AcquisitionService < symphonyui.util.mixin.Observer
    
    events (NotifyAccess = private)
        OpenedExperiment
        ClosedExperiment
        ChangedAvailableRigs
        ChangedAvailableProtocols
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
        
        % Assumes at least one rig and protocol exist in the repos at all times (usually a null object).
        function obj = AcquisitionService(experimentFactory, rigRepository, protocolRepository)
            obj.experimentFactory = experimentFactory;
            
            obj.rigRepository = rigRepository;
            obj.addListener(rigRepository, 'LoadedAll', @(h,d)notify(obj, 'ChangedAvailableRigs'));
            rigs = rigRepository.getAll();
            if isempty(rigs)
                error('At least one rig should exist in the repo');
            end
            if numel(rigs) > 1
                obj.currentRig = rigs{2};
            else
                obj.currentRig = rigs{1};
            end
            
            obj.protocolRepository = protocolRepository;
            obj.addListener(protocolRepository, 'LoadedAll', @(h,d)notify(obj, 'ChangedAvailableProtocols'));
            protocols = protocolRepository.getAll();
            if isempty(protocols)
                error('At least one protocol should exist in the repo');
            end
            if numel(protocols) > 1
                obj.currentProtocol = protocols{2};
            else
                obj.currentProtocol = protocols{1};
            end
        end
        
        function delete(obj)
            delete@symphonyui.util.mixin.Observer(obj);
            delete(obj.rigRepository);
            delete(obj.protocolRepository);
        end
        
        %% Experiment
        
        function createExperiment(obj, name, location)
            if obj.hasCurrentExperiment
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.create(name, location);
            experiment.open();
            obj.currentExperiment = experiment;
            notify(obj, 'OpenedExperiment');
        end
        
        function openExperiment(obj, name, location)
            if obj.hasCurrentExperiment
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.open(name, location);
            obj.currentExperiment = experiment;
            notify(obj, 'OpenedExperiment');
        end
        
        function closeExperiment(obj)
            if ~obj.hasCurrentExperiment
                error('No experiment open');
            end
            obj.currentExperiment.close();
            obj.currentExperiment = [];
            notify(obj, 'ClosedExperiment');
        end
        
        function tf = hasCurrentExperiment(obj)
            tf = ~isempty(obj.currentExperiment);
        end
        
        function e = getCurrentExperiment(obj)
            if ~obj.hasCurrentExperiment
                error('No experiment open');
            end
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

