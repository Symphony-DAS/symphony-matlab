classdef AcquisitionService < symphonyui.infra.mixin.Observer
    
    events (NotifyAccess = private)
        OpenedExperiment
        ClosedExperiment
        SelectedRig
        SelectedProtocol
    end
    
    properties (Access = private)
        experimentFactory
        rigDescriptorRepository
        protocolDescriptorRepository
    end
    
    properties (Access = private)
        session
    end
    
    properties (Constant, Access = private)
        NONE_ID = '(None)';
    end
    
    methods
        
        function obj = AcquisitionService(experimentFactory, rigDescriptorRepository, protocolDescriptorRepository)
            obj.experimentFactory = experimentFactory;
            obj.rigDescriptorRepository = rigDescriptorRepository;
            obj.protocolDescriptorRepository = protocolDescriptorRepository;
        end
        
        function delete(obj)
            if ~isempty(obj.getCurrentExperiment())
                obj.closeExperiment();
            end
        end
        
        %% Experiment
        
        function createExperiment(obj, name, location, purpose)
            if obj.hasCurrentExperiment()
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.create(name, location, purpose);
            experiment.open();
            obj.session.experiment = experiment;
            notify(obj, 'OpenedExperiment');
        end
        
        function openExperiment(obj, path)
            if obj.hasCurrentExperiment()
                error('An experiment is already open');
            end
            experiment = obj.experimentFactory.open(path);
            obj.session.experiment = experiment;
            notify(obj, 'OpenedExperiment');
        end
        
        function closeExperiment(obj)
            if ~obj.hasCurrentExperiment()
                error('No experiment open');
            end
            obj.session.experiment.close();
            obj.session.experiment = [];
            notify(obj, 'ClosedExperiment');
        end
        
        function tf = hasCurrentExperiment(obj)
            tf = ~isempty(obj.getCurrentExperiment());
        end
        
        function e = getCurrentExperiment(obj)
            e = [];
            if isfield(obj.session, 'experiment')
                e = obj.session.experiment;
            end
        end
        
        %% Rig
        
        function i = getAvailableRigIds(obj)
            i = [symphonyui.app.AcquisitionService.NONE_ID, obj.rigDescriptorRepository.getAllIds()];
        end
        
        function selectRig(obj, id)
            obj.getCurrentRig().close();
            
            rig = obj.getRig(id);
            rig.initialize();
            
            obj.session.rig = rig;
            obj.session.rigId = id;
            obj.getCurrentProtocol().setRig(rig);
            
            notify(obj, 'SelectedRig');
        end
        
        function r = getRig(obj, id)
            if strcmp(id, symphonyui.app.AcquisitionService.NONE_ID)
                className = 'symphonyui.infra.nulls.NullRig';
            else
                descriptor = obj.rigDescriptorRepository.get(id);
                className = descriptor.class;
            end
            constructor = str2func(className);
            r = constructor();
        end
        
        function i = getCurrentRigId(obj)
            if isfield(obj.session, 'rigId')
                i = obj.session.rigId;
            else
                i = symphonyui.app.AcquisitionService.NONE_ID;
            end
        end
        
        function r = getCurrentRig(obj)
            if isfield(obj.session, 'rig')
                r = obj.session.rig;
            else
                r = obj.getRig(symphonyui.app.AcquisitionService.NONE_ID);
            end
        end
        
        %% Protocol
        
        function i = getAvailableProtocolIds(obj)
            i = [symphonyui.app.AcquisitionService.NONE_ID, obj.protocolDescriptorRepository.getAllIds()];
        end
        
        function selectProtocol(obj, id)
            obj.session.protocol = obj.getProtocol(id);
            obj.session.protocolId = id;
            obj.session.protocol.setRig(obj.getCurrentRig());
            notify(obj, 'SelectedProtocol');
        end
        
        function p = getProtocol(obj, id)
            if strcmp(id, symphonyui.app.AcquisitionService.NONE_ID)
                className = 'symphonyui.infra.nulls.NullProtocol';
            else
                descriptor = obj.protocolDescriptorRepository.get(id);
                className = descriptor.class;
            end
            constructor = str2func(className);
            p = constructor();
        end
        
        function i = getCurrentProtocolId(obj)
            if isfield(obj.session, 'protocolId')
                i = obj.session.protocolId;
            else
                i = symphonyui.app.AcquisitionService.NONE_ID;
            end
        end
        
        function p = getCurrentProtocol(obj)
            if isfield(obj.session, 'protocol')
                p = obj.session.protocol;
            else
                p = obj.getProtocol(symphonyui.app.AcquisitionService.NONE_ID);
            end
        end
        
        %% Acquisition
        
        function record(obj)
            if obj.hasCurrentExperiment()
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

