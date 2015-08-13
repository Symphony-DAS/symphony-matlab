classdef Controller < symphonyui.core.CoreObject
    
    events
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
            
            if nargin < 1
                daq = [];
            end
            
            if isempty(daq)
                cobj = Symphony.Core.Controller();
            else
                cobj = Symphony.Core.Controller(daq.cobj, daq.cobj.Clock);
            end
            obj@symphonyui.core.CoreObject(cobj);
            
            obj.daqController = daq;
            obj.devices = {};
            
            obj.listeners = {};
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'CompletedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', ...
                @(h,d)notify(obj, 'CompletedEpoch', symphonyui.core.CoreEventData(symphonyui.core.Epoch(d.Epoch))));
            obj.listeners{end + 1} = symphonyui.core.util.NetListener(obj.cobj, 'DiscardedEpoch', 'Symphony.Core.TimeStampedEpochEventArgs', ...
                @(h,d)notify(obj, 'DiscardedEpoch', symphonyui.core.CoreEventData(symphonyui.core.Epoch(d.Epoch))));
        end
        
        function tf = get.isRunning(obj)
            tf = obj.cobj.IsRunning;
        end
        
        function addDevice(obj, device)
            obj.tryCore(@()obj.cobj.AddDevice(device.cobj));
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

