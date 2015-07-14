classdef Persistor < symphonyui.core.CoreObject

    events
        AddedDevice
        AddedSource
        BeganEpochGroup
        EndedEpochGroup
        BeganEpochBlock
        EndedEpochBlock
        DeletedEntity
        Closed
    end

    properties (SetAccess = private)
        isClosed
        experiment
        currentEpochGroup
        currentEpochBlock
    end

    properties (Access = private)
        entityFactory
    end

    methods

        function obj = Persistor(cobj)
            obj@symphonyui.core.CoreObject(cobj);
            obj.entityFactory = symphonyui.core.EntityFactory();
        end

        function delete(obj)
            obj.close();
        end

        function close(obj)
            obj.cobj.Close();
            notify(obj, 'Closed');
        end
        
        function tf = get.isClosed(obj)
            tf = obj.cobj.IsClosed;
        end

        function e = get.experiment(obj)
            e = obj.entityFactory.fromCoreEntity(obj.cobj.Experiment);
        end

        function d = addDevice(obj, name, manufacturer)
            cdev = obj.tryCoreWithReturn(@()obj.cobj.AddDevice(name, manufacturer));
            d = obj.entityFactory.fromCoreEntity(cdev);
            notify(obj, 'AddedDevice', symphonyui.core.util.DomainEventData(d));
        end

        function s = addSource(obj, label, parent)
            if nargin < 3 || isempty(parent)
                cparent = [];
            else
                cparent = parent.cobj;
            end
            csrc = obj.tryCoreWithReturn(@()obj.cobj.AddSource(label, cparent));
            s = obj.entityFactory.fromCoreEntity(csrc);
            notify(obj, 'AddedSource', symphonyui.core.util.DomainEventData(s));
        end

        function g = beginEpochGroup(obj, label, source)
            cgrp = obj.tryCoreWithReturn(@()obj.cobj.BeginEpochGroup(label, source.cobj));
            g = obj.entityFactory.fromCoreEntity(cgrp);
            notify(obj, 'BeganEpochGroup', symphonyui.core.util.DomainEventData(g));
        end

        function g = endEpochGroup(obj)
            cgrp = obj.tryCoreWithReturn(@()obj.cobj.EndEpochGroup());
            g = obj.entityFactory.fromCoreEntity(cgrp);
            notify(obj, 'EndedEpochGroup', symphonyui.core.util.DomainEventData(g));
        end

        function g = get.currentEpochGroup(obj)
            cgrp = obj.cobj.CurrentEpochGroup;
            if isempty(cgrp)
                g = [];
            else
                g = obj.entityFactory.fromCoreEntity(cgrp);
            end
        end

        function b = beginEpochBlock(obj, protocolId, startTime)
            if nargin < 3
                startTime = datetime('now', 'TimeZone', 'local');
            end
            dto = obj.dateTimeOffsetFromDatetime(startTime);
            cblk = obj.tryCoreWithReturn(@()obj.cobj.BeginEpochBlock(protocolId, dto));
            b = obj.entityFactory.fromCoreEntity(cblk);
            notify(obj, 'BeganEpochBlock', symphonyui.core.util.DomainEventData(b));
        end

        function b = endEpochBlock(obj, endTime)
            if nargin < 2
                endTime = datetime('now', 'TimeZone', 'local');
            end
            dto = obj.dateTimeOffsetFromDatetime(endTime);
            cblk = obj.tryCoreWithReturn(@()obj.cobj.EndEpochBlock(dto));
            b = obj.entityFactory.fromCoreEntity(cblk);
            notify(obj, 'EndedEpochBlock', symphonyui.core.util.DomainEventData(b));
        end

        function b = get.currentEpochBlock(obj)
            cblk = obj.cobj.CurrentEpochBlock;
            if isempty(cblk)
                b = [];
            else
                b = obj.entityFactory.fromCoreEntity(cblk);
            end
        end

        function e = serialize(obj, epoch)
            e = symphonyui.core.persistent.Epoch(obj.cobj.Serialize(epoch.cobj));
        end

        function deleteEntity(obj, entity)
            uuid = entity.uuid;
            obj.tryCore(@()obj.cobj.Delete(entity.cobj));
            notify(obj, 'DeletedEntity', symphonyui.core.util.DomainEventData(uuid));
        end

    end

end