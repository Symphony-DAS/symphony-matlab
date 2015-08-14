classdef Controller < symphonyui.core.CoreObject
    
    events
        Started
        RequestedStop
        Stopped
        CompletedEpoch
        DiscardedEpoch
    end
    
    properties (SetAccess = private)
        isRunning
        daqController
        devices
    end
    
    properties (Access = private)
        listeners
    end
    
    methods
        
        function obj = Controller(daq)
            import symphonyui.core.util.*;
            
            cobj = Symphony.Core.Controller(daq.cobj, daq.cobj.Clock);
            obj@symphonyui.core.CoreObject(cobj);
            
            obj.daqController = daq;
            obj.devices = {};
            
            obj.listeners = {};
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'Started', 'Symphony.Core.TimeStampedEventArgs', ...
                @(h,d)notify(obj, 'Started'));
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'RequestedStop', 'Symphony.Core.TimeStampedEventArgs', ...
                @(h,d)notify(obj, 'RequestedStop'));
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'Stopped', 'Symphony.Core.TimeStampedEventArgs', ...
                @(h,d)notify(obj, 'Stopped'));
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'CompletedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', ...
                @(h,d)notify(obj, 'CompletedEpoch', symphonyui.core.CoreEventData(symphonyui.core.Epoch(d.Epoch))));
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'DiscardedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', ...
                @(h,d)notify(obj, 'DiscardedEpoch', symphonyui.core.CoreEventData(symphonyui.core.Epoch(d.Epoch))));
        end
        
        function delete(obj)
            while ~isempty(obj.listeners)
                delete(obj.listeners{1});
                obj.listeners(1) = [];
            end
            disp('deleted controller');
        end
        
        function tf = get.isRunning(obj)
            tf = obj.cobj.IsRunning;
        end
        
        function addDevice(obj, device)
            obj.tryCore(@()obj.cobj.AddDevice(device.cobj));
            device.cobj.Clock = obj.cobj.Clock;
            obj.devices{end + 1} = device;
        end
        
        function d = getDevice(obj, name)
            d = [];
            for i = numel(obj.devices)
                if strcmp(obj.devices{i}.name, name)
                    d = obj.devices{i};
                    return;
                end
            end
        end
        
        function clearEpochQueue(obj)
            obj.tryCore(@()obj.cobj.ClearEpochQueue());
        end
        
        function enqueueEpoch(obj, epoch)
            obj.tryCore(@()obj.cobj.EnqueueEpoch(epoch.cobj));
        end
        
        function t = startAsync(obj, persistor)
            if isempty(persistor)
                cper = [];
            else
                cper = persistor.cobj;
            end
            t = obj.tryCoreWithReturn(@()obj.cobj.StartAsync(cper));
        end
        
        function requestStop(obj)
            obj.tryCore(@()obj.cobj.RequestStop());
        end
        
    end
    
end

