classdef Rig < handle
    
    properties (SetObservable, SetAccess = private)
        state = symphonyui.core.RigState.STOPPED
    end
    
    properties
        controller
    end
    
    methods
        
        function obj = Rig(description)
            if nargin < 1
                description = symphonyui.core.descriptions.RigDescription();
            end
            
            obj.controller = symphonyui.core.Controller(description.daqController);
            
            devs = description.devices;
            for i = 1:numel(devs)
                obj.controller.addDevice(devs{i});
            end
        end
        
        function initialize(obj)
            daq = obj.controller.daqController;
            if ~isempty(daq)
                daq.initialize();
            end
        end
        
        function close(obj)
            daq = obj.controller.daqController;
            if ~isempty(daq)
                daq.close();
            end
        end
        
        function runProtocol(obj, protocol, persistor)
            if obj.state ~= symphonyui.core.RigState.STOPPED
                error('Rig is not stopped');
            end
            
            protocol.prepareRun();
            
            if isempty(persistor)
                obj.state = symphonyui.core.RigState.VIEWING;
            else
                obj.state = symphonyui.core.RigState.RECORDING;
            end
            
            epochCompleted = addlistener(obj.controller, 'CompletedEpoch', @(h,d)obj.onCompletedEpoch(protocol, d.data));
            deleteEpochCompleted = onCleanup(@()delete(epochCompleted));
            
            epochDiscarded = addlistener(obj.controller, 'DiscardedEpoch', @(h,d)obj.onDiscardedEpoch(protocol, d.data));
            deleteEpochDiscarded = onCleanup(@()delete(epochDiscarded));
            
            obj.process(protocol, persistor);
            
            protocol.completeRun();
        end
        
        function requestStop(obj)
            obj.controller.requestStop();
            obj.state = symphonyui.core.RigState.STOPPING;
        end
        
        function [tf, msg] = isValid(obj)
            tf = true;
            msg = [];
        end
        
    end
    
    methods (Access = private)
        
        function onCompletedEpoch(obj, protocol, epoch)
            protocol.completeEpoch(epoch);
            if ~protocol.continueRun()
                obj.requestStop();
            end
        end
        
        function onDiscardedEpoch(obj, protocol, epoch) %#ok<INUSD>
            obj.requestStop();
        end
        
        function process(obj, protocol, persistor)
            obj.controller.startAsync(persistor);
            
            while protocol.continueQueuing()
                epoch = symphonyui.core.Epoch(Symphony.Core.Epoch(class(protocol)));
                protocol.prepareEpoch(epoch);
                obj.controller.enqueueEpoch(epoch);
            end
            
            while obj.controller.isRunning
                pause(0.01);
            end
        end
        
    end
    
end

