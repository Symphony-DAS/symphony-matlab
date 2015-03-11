classdef MainView < symphonyui.ui.View
    
    events
        NewExperiment
        CloseExperiment
        Exit
        BeginEpochGroup
        EndEpochGroup
        AddNote
        ViewExperiment
        SelectedProtocol
        ChangedProtocolParameters
        Record
        Preview
        Pause
        Stop
        SelectRig
        ViewRig
        Settings
        Documentation
        UserGroup
        AboutSymphony
    end
    
    properties (Access = private)
        fileMenu
        experimentMenu
        acquireMenu
        toolsMenu
        helpMenu
        protocolDropDown
        protocolParameterGrid
        recordButton
        previewButton
        pauseButton
        stopButton
        statusText
    end
    
    methods
        
        function createUi(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Position', screenCenter(280, 350));
            
            % File menu.
            obj.fileMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'File');
            obj.fileMenu.newExperiment = uimenu(obj.fileMenu.root, ...
                'Label', 'New Experiment...', ...
                'Callback', @(h,d)notify(obj, 'NewExperiment'));
            obj.fileMenu.closeExperiment = uimenu(obj.fileMenu.root, ...
                'Label', 'Close Experiment', ...
                'Callback', @(h,d)notify(obj, 'CloseExperiment'));
            obj.fileMenu.exit = uimenu(obj.fileMenu.root, ...
                'Label', 'Exit', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Exit'));
            
            % Experiment menu.
            obj.experimentMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Experiment');
            obj.experimentMenu.beginEpochGroup = uimenu(obj.experimentMenu.root, ...
                'Label', 'Begin Epoch Group...', ...
                'Callback', @(h,d)notify(obj, 'BeginEpochGroup'));
            obj.experimentMenu.endEpochGroup = uimenu(obj.experimentMenu.root, ...
                'Label', 'End Epoch Group', ...
                'Callback', @(h,d)notify(obj, 'EndEpochGroup'));
            obj.experimentMenu.addNote = uimenu(obj.experimentMenu.root, ...
                'Label', 'Add Note...', ...
                'Separator', 'on', ...
                'Accelerator', 't', ...
                'Callback', @(h,d)notify(obj, 'AddNote'));
            obj.experimentMenu.viewExperiment = uimenu(obj.experimentMenu.root, ...
                'Label', 'View Experiment', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'ViewExperiment'));
            
            % Acquire menu.
            obj.acquireMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Acquire');
            obj.acquireMenu.record = uimenu(obj.acquireMenu.root, ...
                'Label', 'Record', ...
                'Accelerator', 'r', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.acquireMenu.preview = uimenu(obj.acquireMenu.root, ...
                'Label', 'Preview', ...
                'Accelerator', 'v', ...
                'Callback', @(h,d)notify(obj, 'Preview'));
            obj.acquireMenu.pause = uimenu(obj.acquireMenu.root, ...
                'Label', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.acquireMenu.stop = uimenu(obj.acquireMenu.root, ...
                'Label', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));
            
            % Tools menu.
            obj.toolsMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Tools');
            obj.toolsMenu.modulesMenu.root = uimenu(obj.toolsMenu.root, ...
                'Label', 'Modules');
            obj.toolsMenu.selectRig = uimenu(obj.toolsMenu.root, ...
                'Label', 'Select Rig...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'SelectRig'));
            obj.toolsMenu.viewRig = uimenu(obj.toolsMenu.root, ...
                'Label', 'View Rig', ...
                'Callback', @(h,d)notify(obj, 'ViewRig'));
            obj.toolsMenu.settings = uimenu(obj.toolsMenu.root, ...
                'Label', 'Settings...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Settings'));
            
            % Help menu.
            obj.helpMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Help');
            obj.helpMenu.documentation = uimenu(obj.helpMenu.root, ...
                'Label', 'Documentation', ...
                'Callback', @(h,d)notify(obj, 'Documentation'));
            obj.helpMenu.userGroup = uimenu(obj.helpMenu.root, ...
                'Label', 'User Group', ...
                'Callback', @(h,d)notify(obj, 'UserGroup'));
            obj.helpMenu.about = uimenu(obj.helpMenu.root, ...
                'Label', 'About Symphony', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'AboutSymphony'));
            
            iconsFolder = fullfile(symphonyui.app.App.rootPath, 'resources', 'icons');
            if iconsFolder(1) == filesep
                iconsFolder(1) = [];
            end
            iconsUrl = strrep(['file:/' iconsFolder '/'],'\','/');
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            obj.protocolDropDown = createDropDownMenu(mainLayout, {''});
            set(obj.protocolDropDown, 'Callback', @(h,d)notify(obj, 'SelectedProtocol'));
            
            obj.protocolParameterGrid = PropertyGrid(mainLayout);
            addlistener(obj.protocolParameterGrid, 'ChangedProperty', @(h,d)notify(obj, 'ChangedProtocolParameters'));
            
            controlsLayout = uiextras.VBox( ...
                'Parent', mainLayout);
            layout = uiextras.HBox( ...
                'Parent', controlsLayout, ...
                'Spacing', 1);
            obj.recordButton = uicontrol( ...
                'Parent', layout, ...        
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'record.png'] '"/></html>'], ...
                'TooltipString', 'Record', ...
                'Callback', @(h,d)notify(obj, 'Record'));
            obj.previewButton = uicontrol( ...
                'Parent', layout, ...        
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'preview.png'] '"/></html>'], ...
                'TooltipString', 'Preview', ...
                'Callback', @(h,d)notify(obj, 'Preview'));
            obj.pauseButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'pause.png'] '"/></html>'], ...
                'TooltipString', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.stopButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'stop.png'] '"/></html>'], ...
                'TooltipString', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));
            
            layout = uiextras.HBox( ...
                'Parent', controlsLayout);
            obj.statusText = createLabel(layout, 'Status');
            
            set(controlsLayout, 'Sizes', [-1 25]);
            
            set(mainLayout, 'Sizes', [25 -1 65]);
        end
        
        function close(obj)
            close@symphonyui.ui.View(obj);
            obj.protocolParameterGrid.Close();
        end
        
        function setTitle(obj, t)
            set(obj.figureHandle, 'Name', t);
        end
        
        function enableNewExperiment(obj, tf)
            set(obj.fileMenu.newExperiment, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableCloseExperiment(obj, tf)
            set(obj.fileMenu.closeExperiment, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableBeginEpochGroup(obj, tf)
            set(obj.experimentMenu.beginEpochGroup, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableEndEpochGroup(obj, tf)
            set(obj.experimentMenu.endEpochGroup, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableAddNote(obj, tf)
            set(obj.experimentMenu.addNote, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableViewExperiment(obj, tf)
            set(obj.experimentMenu.viewExperiment, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableSelectRig(obj, tf)
            set(obj.toolsMenu.selectRig, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableViewRig(obj, tf)
            set(obj.toolsMenu.viewRig, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableSettings(obj, tf)
            set(obj.toolsMenu.settings, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableSelectProtocol(obj, tf)
            set(obj.protocolDropDown, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function p = getSelectedProtocol(obj)
            p = symphonyui.util.ui.getSelectedValue(obj.protocolDropDown);
        end
        
        function setSelectedProtocol(obj, p)
            symphonyui.util.ui.setSelectedValue(obj.protocolDropDown, p);
        end
        
        function setProtocolList(obj, p)
            symphonyui.util.ui.setStringList(obj.protocolDropDown, p);
        end
        
        function enableProtocolParameters(obj, tf)
            set(obj.protocolParameterGrid, 'Enable', tf);
        end
        
        function p = getProtocolParameters(obj)
            properties = get(obj.protocolParameterGrid, 'Properties');
            p = fieldsToParameters(properties);
        end
        
        function setProtocolParameters(obj, parameters)
            properties = parametersToFields(parameters);
            set(obj.protocolParameterGrid, 'Properties', properties);
        end
        
        function updateProtocolParameters(obj, parameters)
            properties = parametersToFields(parameters);
            obj.protocolParameterGrid.UpdateProperties(properties);
        end
        
        function enableRecord(obj, tf)
            enable = symphonyui.util.onOff(tf);
            set(obj.acquireMenu.record, 'Enable', enable);
            set(obj.recordButton, 'Enable', enable);
        end
        
        function enablePreview(obj, tf)
            enable = symphonyui.util.onOff(tf);
            set(obj.acquireMenu.preview, 'Enable', enable);
            set(obj.previewButton, 'Enable', enable);
        end
        
        function enablePause(obj, tf)
            enable = symphonyui.util.onOff(tf);
            set(obj.acquireMenu.pause, 'Enable', enable);
            set(obj.pauseButton, 'Enable', enable);
        end
        
        function enableStop(obj, tf)
            enable = symphonyui.util.onOff(tf);
            set(obj.acquireMenu.stop, 'Enable', enable);
            set(obj.stopButton, 'Enable', enable);
        end
        
        function setStatus(obj, s)
            set(obj.statusText, 'String', s);
        end
        
    end
    
end

function fields = parametersToFields(parameters)
    fields = PropertyGridField.empty(0, 1);
    if isempty(parameters)
        return;
    end
    
    for i = 1:numel(parameters)
        p = parameters(i);
        
        description = p.description;
        if ~isempty(p.units)
            description = [description ' (' p.units ')']; %#ok<AGROW>
        end

        f = PropertyGridField(p.name, p.value, ...
            'DisplayName', p.displayName, ...
            'Description', description, ...
            'ReadOnly', p.isReadOnly, ...
            'Dependent', p.isDependent);
        if ~isempty(p.type)
            set(f, 'Type', PropertyType(p.type.primitiveType, p.type.shape, p.type.domain));
        end
        if ~isempty(p.category)
            set(f, 'Category', p.category);
        end
        fields(end + 1) = f; %#ok<AGROW>
    end
end

function parameters = fieldsToParameters(fields)
    % TODO: Parse description into description and units.
    import symphonyui.core.*;
    
    parameters = Parameter.empty(0, 1);    
    if isempty(fields)
        return;
    end
    
    for i = 1:numel(fields)
        f = fields(i);
        p = symphonyui.core.Parameter(f.Name, f.Value, ...
            'type', ParameterType(f.Type.PrimitiveType, f.Type.Shape, f.Type.Domain), ...
            'category', f.Category, ...
            'displayName', f.DisplayName, ...
            'description', f.Description, ...
            'isReadOnly', f.ReadOnly, ...
            'isDependent', f.Dependent);
        parameters(end + 1) = p;
    end
end