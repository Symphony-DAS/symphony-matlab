classdef ProtocolPresetsPresenter < appbox.Presenter

    properties (Access = private)
        log
        settings
        documentationService
        acquisitionService
        configurationService
    end

    methods

        function obj = ProtocolPresetsPresenter(documentationService, acquisitionService, configurationService, view)
            if nargin < 4
                view = symphonyui.ui.views.ProtocolPresetsView();
            end
            obj = obj@appbox.Presenter(view);

            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.settings = symphonyui.ui.settings.ProtocolPresetsSettings();
            obj.documentationService = documentationService;
            obj.acquisitionService = acquisitionService;
            obj.configurationService = configurationService;
        end

    end

    methods (Access = protected)

        function willGo(obj)
            obj.populatePresetList();
            try
                obj.loadSettings();
            catch x
                obj.log.debug(['Failed to load presenter settings: ' x.message], x);
            end
            obj.updateStateOfControls();
        end

        function willStop(obj)
            try
                obj.saveSettings();
            catch x
                obj.log.debug(['Failed to save presenter settings: ' x.message], x);
            end
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'SelectedProtocolPreset', @obj.onViewSelectedProtocolPreset);
            obj.addListener(v, 'ViewOnlyProtocolPreset', @obj.onViewSelectedViewOnlyProtocolPreset);
            obj.addListener(v, 'RecordProtocolPreset', @obj.onViewSelectedRecordProtocolPreset);
            obj.addListener(v, 'StopProtocolPreset', @obj.onViewSelectedStopProtocolPreset);
            obj.addListener(v, 'AddProtocolPreset', @obj.onViewSelectedAddProtocolPreset);
            obj.addListener(v, 'RemoveProtocolPreset', @obj.onViewSelectedRemoveProtocolPreset);
            obj.addListener(v, 'ApplyProtocolPreset', @obj.onViewSelectedApplyProtocolPreset);
            obj.addListener(v, 'UpdateProtocolPreset', @obj.onViewSelectedUpdateProtocolPreset);

            d = obj.documentationService;
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);

            a = obj.acquisitionService;
            obj.addListener(a, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
            obj.addListener(a, 'SetProtocolProperties', @obj.onServiceSetProtocolProperties);
            obj.addListener(a, 'ChangedControllerState', @obj.onServiceChangedControllerState);
            obj.addListener(a, 'AddedProtocolPreset', @obj.onServiceAddedProtocolPreset);
            obj.addListener(a, 'RemovedProtocolPreset', @obj.onServiceRemovedProtocolPreset);
        end

    end

    methods (Access = private)

        function populatePresetList(obj)
            names = obj.acquisitionService.getAvailableProtocolPresets();

            data = cell(numel(names), 2);
            for i = 1:numel(names)
                preset = obj.acquisitionService.getProtocolPreset(names{i});
                data{i, 1} = preset.name;
                data{i, 2} = preset.protocolId;
            end

            obj.view.setProtocolPresets(data);
        end
        
        function onViewSelectedProtocolPreset(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function onViewSelectedViewOnlyProtocolPreset(obj, ~, event)
            options = obj.configurationService.getOptions();
            if obj.documentationService.hasOpenFile() && options.warnOnViewOnlyWithOpenFile
                [result, dontShow] = obj.view.showMessage( ...
                    'Are you sure you want to run "View Only"? No data will be saved to your file.', 'Warning', ...
                    'button1', 'Cancel', ...
                    'button2', 'View Only', ...
                    'checkbox', 'Don''t show this message again', ...
                    'default', 2);
                if ~strcmp(result, 'View Only')
                    return;
                end
                if dontShow
                    options.warnOnViewOnlyWithOpenFile = false;
                end
            end
            
            data = event.data;
            presets = obj.view.getProtocolPresets();
            name = presets{data.getEditingRow(), 1};
            try
                obj.acquisitionService.applyProtocolPreset(name);
                obj.acquisitionService.viewOnly();
            catch x
                msg = x.message;
                for i = 1:numel(x.cause)
                    msg = sprintf('%s\n- %s', msg, x.cause{i}.message);
                end
                obj.log.debug(msg, x);
                obj.view.showError(msg);
                return;
            end
        end

        function onViewSelectedRecordProtocolPreset(obj, ~, event)
            data = event.data;
            presets = obj.view.getProtocolPresets();
            name = presets{data.getEditingRow(), 1};
            try
                obj.acquisitionService.applyProtocolPreset(name);
                obj.acquisitionService.record();
            catch x
                msg = x.message;
                for i = 1:numel(x.cause)
                    msg = sprintf('%s\n- %s', msg, x.cause{i}.message);
                end
                obj.log.debug(msg, x);
                obj.view.showError(msg);
                return;
            end
        end

        function onViewSelectedStopProtocolPreset(obj, ~, ~)
            try
                obj.acquisitionService.requestStop();
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onViewSelectedAddProtocolPreset(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddProtocolPresetPresenter(obj.acquisitionService);
            presenter.goWaitStop();
        end

        function onServiceAddedProtocolPreset(obj, ~, event)
            preset = event.data;
            obj.view.addProtocolPreset(preset.name, preset.protocolId);
        end

        function onViewSelectedRemoveProtocolPreset(obj, ~, ~)
            name = obj.view.getSelectedProtocolPreset();
            if ~ischar(name)
                return;
            end
            try
                obj.acquisitionService.removeProtocolPreset(name);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceRemovedProtocolPreset(obj, ~, event)
            preset = event.data;
            obj.view.removeProtocolPreset(preset.name);
        end
        
        function onViewSelectedApplyProtocolPreset(obj, ~, ~)
            name = obj.view.getSelectedProtocolPreset();
            if ~ischar(name)
                return;
            end
            try
                obj.acquisitionService.applyProtocolPreset(name);
            catch x
                msg = x.message;
                for i = 1:numel(x.cause)
                    msg = sprintf('%s\n- %s', msg, x.cause{i}.message);
                end
                obj.log.debug(msg, x);
                obj.view.showError(msg);
                return;
            end
        end
        
        function onViewSelectedUpdateProtocolPreset(obj, ~, ~)
            name = obj.view.getSelectedProtocolPreset();
            if ~ischar(name)
                return;
            end
            try
                obj.acquisitionService.updateProtocolPreset(name);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                return;
            end
        end

        function onServiceBeganEpochGroup(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function onServiceEndedEpochGroup(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onServiceSelectedProtocol(obj, ~, ~)
            obj.updateStateOfControls();
        end
        
        function onServiceSetProtocolProperties(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function onServiceChangedControllerState(obj, ~, ~)
            obj.updateStateOfControls();
        end

        function updateStateOfControls(obj)
            import symphonyui.core.ControllerState;

            hasOpenFile = obj.documentationService.hasOpenFile();
            hasEpochGroup = hasOpenFile && ~isempty(obj.documentationService.getCurrentEpochGroup());
            controllerState = obj.acquisitionService.getControllerState();
            isStopping = controllerState.isStopping();
            isStopped = controllerState.isStopped();
            [~, id] = obj.view.getSelectedProtocolPreset();
            isProtocolIdEqual = strcmp(id, obj.acquisitionService.getSelectedProtocol());
            try
                isValid = obj.acquisitionService.isValid();
            catch
                isValid = false;
            end
            
            enableViewOnlyProtocolPreset = isStopped;
            enableRecordProtocolPreset = hasEpochGroup && isStopped;
            enableStopProtocolPreset = ~isStopping && ~isStopped;
            enableAddProtocolPreset = isValid;
            enableUpdateProtocolPreset = isValid && isProtocolIdEqual;
            
            obj.view.enableViewOnlyProtocolPreset(enableViewOnlyProtocolPreset);
            obj.view.enableRecordProtocolPreset(enableRecordProtocolPreset);
            obj.view.enableStopProtocolPreset(enableStopProtocolPreset);
            obj.view.enableAddProtocolPreset(enableAddProtocolPreset);
            obj.view.enableUpdateProtocolPreset(enableUpdateProtocolPreset);
            
            if ~enableViewOnlyProtocolPreset
                obj.view.stopEditingViewOnlyProtocolPreset();
            end
            if ~enableRecordProtocolPreset
                obj.view.stopEditingRecordProtocolPreset();
            end
        end

        function loadSettings(obj)
            if ~isempty(obj.settings.viewPosition)
                obj.view.position = obj.settings.viewPosition;
            end
        end

        function saveSettings(obj)
            obj.settings.viewPosition = obj.view.position;
            obj.settings.save();
        end

    end

end
