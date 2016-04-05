classdef EntityPresetsPresenter < appbox.Presenter

    properties (Access = private)
        log
        documentationService
        entitySet
    end

    methods

        function obj = EntityPresetsPresenter(documentationService, entitySet, view)
            if nargin < 3
                view = symphonyui.ui.views.EntityPresetsView();
            end
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.documentationService = documentationService;
            obj.entitySet = entitySet;
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.populatePresetList();
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'RemoveEntityPreset', @obj.onViewSelectedRemoveEntityPreset);
            obj.addListener(v, 'Ok', @obj.onViewSelectedOk);

            d = obj.documentationService;
            obj.addListener(d, 'RemovedEntityPreset', @obj.onServiceRemovedEntityPreset);
        end

    end

    methods (Access = private)

        function populatePresetList(obj)
            entityType = obj.entitySet.getEntityType();
            descriptionType = obj.entitySet.getDescriptionType();
            names = obj.documentationService.getAvailableEntityPresets(entityType, descriptionType);

            data = cell(numel(names), 2);
            for i = 1:numel(names)
                preset = obj.documentationService.getEntityPreset(names{i}, entityType, descriptionType);
                data{i, 1} = preset.name;
            end

            obj.view.setEntityPresets(data);
        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case {'return', 'escape'}
                    obj.onViewSelectedOk();
            end
        end

        function onViewSelectedRemoveEntityPreset(obj, ~, event)
            data = event.data;
            presets = obj.view.getEntityPresets();
            name = presets{data.getEditingRow() + 1, 1};
            try
                obj.documentationService.removeEntityPreset(name, obj.entitySet.getEntityType(), obj.entitySet.getDescriptionType());
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceRemovedEntityPreset(obj, ~, event)
            preset = event.data;
            obj.view.removeEntityPreset(preset.name);
        end

        function onViewSelectedOk(obj, ~, ~)
            obj.stop();
        end

    end

end
