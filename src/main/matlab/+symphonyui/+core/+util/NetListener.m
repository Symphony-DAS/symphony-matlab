classdef NetListener < handle
    
    properties (Access = private)
        target
        event
        listener
    end
    
    methods
        
        function obj = NetListener(target, eventName, eventType, callback)
            obj.target = target;
            obj.event = obj.target.GetType().GetEvent(eventName);
            obj.listener = NET.createGeneric('System.EventHandler', {eventType}, callback);
            obj.event.AddEventHandler(obj.target, obj.listener);
        end
        
        function delete(obj)
            obj.event.RemoveEventHandler(obj.target, obj.listener);

            % We need to force .NET garbage collection or MATLAB's GC will not be able to collect the callback (locking 
            % class definitions and causing a possible memory leak).
            delete(obj.listener);
            System.GC.Collect();
        end
        
    end
    
end

