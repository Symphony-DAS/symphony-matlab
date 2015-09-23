classdef Persistor < symphonyui.core.CoreObject

    properties (SetAccess = private)
        isClosed
        experiment
        currentEpochGroup
        currentEpochBlock
    end

    methods

        function obj = Persistor(cobj)
            obj@symphonyui.core.CoreObject(cobj);
        end

        function delete(obj)
            obj.close();
        end

        function close(obj)
            obj.cobj.Close();
        end
        
        function tf = get.isClosed(obj)
            tf = obj.cobj.IsClosed;
        end
        
        function e = get.experiment(obj)
            e = symphonyui.core.persistent.Experiment(obj.cobj.Experiment);
        end

        function d = addDevice(obj, name, manufacturer)
            cdev = obj.tryCoreWithReturn(@()obj.cobj.AddDevice(name, manufacturer));
            d = symphonyui.core.persistent.Device(cdev);
        end

        function s = addSource(obj, parent, description)
            if ischar(description)
                l = description;
                description = symphonyui.core.descriptions.SourceDescription();
                description.label = l;
            end
            if isempty(parent)
                cparent = [];
            else
                cparent = parent.cobj;
            end
            csrc = obj.tryCoreWithReturn(@()obj.cobj.AddSource(description.label, cparent));
            try
                s = symphonyui.core.persistent.Source.newSource(csrc, description);
            catch x
                obj.tryCore(@()obj.cobj.Delete(csrc));
                rethrow(x);
            end
        end

        function g = beginEpochGroup(obj, source, description)
            if ischar(description)
                label = description;
                description = symphonyui.core.descriptions.EpochGroupDescription();
                description.label = label;
            end
            cgrp = obj.tryCoreWithReturn(@()obj.cobj.BeginEpochGroup(description.label, source.cobj));
            try
                g = symphonyui.core.persistent.EpochGroup.newEpochGroup(cgrp, description);
            catch x
                obj.endEpochGroup();
                obj.tryCore(@()obj.cobj.Delete(cgrp));
                rethrow(x);
            end
        end

        function g = endEpochGroup(obj)
            cgrp = obj.tryCoreWithReturn(@()obj.cobj.EndEpochGroup());
            g = symphonyui.core.persistent.EpochGroup(cgrp);
        end

        function g = get.currentEpochGroup(obj)
            cgrp = obj.cobj.CurrentEpochGroup;
            if isempty(cgrp)
                g = [];
            else
                g = symphonyui.core.persistent.EpochGroup(cgrp);
            end
        end

        function b = beginEpochBlock(obj, protocolId, parametersMap, startTime)
            if nargin < 4
                startTime = datetime('now', 'TimeZone', 'local');
            end
            dto = obj.dateTimeOffsetFromDatetime(startTime);
            params = obj.dictionaryFromMap(parametersMap);
            cblk = obj.tryCoreWithReturn(@()obj.cobj.BeginEpochBlock(protocolId, params, dto));
            b = symphonyui.core.persistent.EpochBlock(cblk);
        end

        function b = endEpochBlock(obj, endTime)
            if nargin < 2
                endTime = datetime('now', 'TimeZone', 'local');
            end
            dto = obj.dateTimeOffsetFromDatetime(endTime);
            cblk = obj.tryCoreWithReturn(@()obj.cobj.EndEpochBlock(dto));
            b = symphonyui.core.persistent.EpochBlock(cblk);
        end

        function b = get.currentEpochBlock(obj)
            cblk = obj.cobj.CurrentEpochBlock;
            if isempty(cblk)
                b = [];
            else
                b = symphonyui.core.persistent.EpochBlock(cblk);
            end
        end

        function deleteEntity(obj, entity)
            obj.tryCore(@()obj.cobj.Delete(entity.cobj));
        end

    end
    
    methods (Static)
        
        function p = newPersistor(cobj, description)
            symphonyui.core.persistent.Experiment.newExperiment(cobj.Experiment, description);
            p = symphonyui.core.Persistor(cobj);
        end
        
    end

end
