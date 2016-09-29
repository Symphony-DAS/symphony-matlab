classdef Persistor < symphonyui.core.CoreObject
    % A Persistor exposes the persistent model that allows persisted objects to be annotated and modified after
    % persistence.
    %
    % The persistent hierarchy:
    %
    % Experiment
    %   Devices
    %   Sources
    %       Sources (nestable)
    %   EpochGroups
    %       EpochGroups (nestable)
    %       EpochBlocks
    %           Epochs
    %               Backgrounds
    %               Responses
    %               Stimuli

    properties (SetAccess = private)
        isClosed            % Indicates if this persistor is closed
        experiment          % Root entity of the persistent hierarchy
        currentEpochGroup   % Currently open epoch group or empty if no epoch group is open
        currentEpochBlock   % Currently open epoch block or empty if no epoch block is open
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
            % Adds a new device to the persistent hierarchy
            
            cdev = obj.tryCoreWithReturn(@()obj.cobj.AddDevice(name, manufacturer));
            d = symphonyui.core.persistent.Device(cdev);
        end

        function d = device(obj, name, manufacturer)
            cdev = obj.tryCoreWithReturn(@()obj.cobj.Device(name, manufacturer));
            d = symphonyui.core.persistent.Device(cdev);
        end

        function s = addSource(obj, parent, description)
            % Adds a new source to the persistent hierarchy
            
            if ischar(description)
                l = description;
                description = symphonyui.core.persistent.descriptions.SourceDescription();
                description.label = l;
            end
            if isempty(parent)
                cparent = [];
                parentType = [];
            else
                cparent = parent.cobj;
                parentType = parent.getDescriptionType();
            end
            allowableParentTypes = description.getAllowableParentTypes();
            if ~isempty(allowableParentTypes) && ~any(cellfun(@(t)isequal(t, parentType), allowableParentTypes))
                error('Parent type is not in allowable parent types');
            end
            csrc = obj.tryCoreWithReturn(@()obj.cobj.AddSource(description.label, cparent));
            try
                s = symphonyui.core.persistent.Source.newSource(csrc, description);
            catch x
                obj.tryCore(@()obj.cobj.Delete(csrc));
                rethrow(x);
            end
        end

        function g = beginEpochGroup(obj, source, description, propertyMap)
            % Begins a new epoch group, a logical group of consecutive epoch blocks
            
            if nargin < 4
                propertyMap = containers.Map();
            end
            if ischar(description)
                label = description;
                description = symphonyui.core.persistent.descriptions.EpochGroupDescription();
                description.label = label;
            end
            parent = obj.currentEpochGroup;
            if isempty(parent)
                parentType = [];
            else
                parentType = parent.getDescriptionType();
            end
            allowableParentTypes = description.getAllowableParentTypes();
            if ~isempty(allowableParentTypes) && ~any(cellfun(@(t)isequal(t, parentType), allowableParentTypes))
                error('Parent type is not in allowable parent types');
            end
            cgrp = obj.tryCoreWithReturn(@()obj.cobj.BeginEpochGroup(description.label, source.cobj));
            try
                g = symphonyui.core.persistent.EpochGroup.newEpochGroup(cgrp, description);
                g.setPropertyMap(propertyMap);
            catch x
                obj.endEpochGroup();
                obj.tryCore(@()obj.cobj.Delete(cgrp));
                rethrow(x);
            end
        end

        function g = endEpochGroup(obj)
            % Ends the current epoch group
            
            cgrp = obj.tryCoreWithReturn(@()obj.cobj.EndEpochGroup());
            g = symphonyui.core.persistent.EpochGroup(cgrp);
        end
        
        function [g1, g2] = splitEpochGroup(obj, group, block)
            % Splits the epoch group after the given epoch block
            
            csplit = obj.tryCoreWithReturn(@()obj.cobj.SplitEpochGroup(group.cobj, block.cobj));
            g1 = symphonyui.core.persistent.EpochGroup(csplit.Item1);
            g2 = symphonyui.core.persistent.EpochGroup(csplit.Item2);
        end
        
        function g = mergeEpochGroups(obj, group1, group2)
            % Merges group1 into group2
            
            cgrp = obj.tryCoreWithReturn(@()obj.cobj.MergeEpochGroups(group1.cobj, group2.cobj));
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

        function b = beginEpochBlock(obj, protocolId, parametersMap)
            % Begins a new epoch block, a logical group of consectutive epochs produced by a single protocol run
            
            params = obj.dictionaryFromMap(parametersMap);
            cblk = obj.tryCoreWithReturn(@()obj.cobj.BeginEpochBlock(protocolId, params));
            b = symphonyui.core.persistent.EpochBlock(cblk);
        end

        function b = endEpochBlock(obj)
            % Ends the current epoch block
            
            cblk = obj.tryCoreWithReturn(@()obj.cobj.EndEpochBlock());
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
            % Deletes the given persistent entity from the persistent medium
            
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
