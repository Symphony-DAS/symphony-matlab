classdef EpochPersistor < symphonyui.core.CoreObject
    
    properties (SetAccess = private)
        experiment
    end
    
    methods
        
        function obj = EpochPersistor(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end
        
        function delete(obj)
            obj.close();
        end
        
        function close(obj)
            obj.cobj.Close();
        end
        
        function e = get.experiment(obj)
            e = symphonyui.core.persistent.Experiment(obj.cobj.Experiment);
        end
        
        function d = addDevice(obj, name, manufacturer)
            d = symphonyui.core.persistent.Device(obj.cobj.AddDevice(name, manufacturer));
        end
        
        function s = addSource(obj, label, parent)
            if nargin < 3 || isempty(parent)
                cparent = [];
            else
                cparent = parent.cobj;
            end
            s = symphonyui.core.persistent.Source(obj.cobj.AddSource(label, cparent));
        end
        
        function g = beginEpochGroup(obj, label, source)
            g = symphonyui.core.persistent.EpochGroup(obj.cobj.BeginEpochGroup(label, source.cobj));
        end
        
        function g = endEpochGroup(obj)
            g = symphonyui.core.persistent.EpochGroup(obj.cobj.EndEpochGroup());
        end
        
        function b = beginEpochBlock(obj, protocolId, startTime)
            dto = obj.dateTimeOffsetFromDatetime(startTime);
            b = symphonyui.core.persistent.EpochBlock(obj.cobj.BeginEpochBlock(protocolId, dto));
        end
        
        function b = endEpochBlock(obj, endTime)
            dto = obj.dateTimeOffsetFromDatetime(endTime);
            b = symphonyui.core.persistent.EpochBlock(obj.cobj.EndEpochBlock(dto));
        end
        
        function e = serialize(obj, epoch)
            e = symphonyui.core.persistent.Epoch(obj.cobj.Serialize(epoch.cobj));
        end
        
        function deleteEntity(obj, entity)
            obj.cobj.Delete(entity.cobj);
        end
        
    end
    
end

