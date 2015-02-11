classdef MainView < symphonyui.View
    
    events
        NewExperiment
        CloseExperiment
        Exit
        BeginEpochGroup
        EndEpochGroup
        SelectedProtocol
        ChangedProtocolParameters
        Run
        Pause
        Stop
        SelectRig
        ViewRig
        Preferences
        Documentation
        UserGroup
        AboutSymphony
    end
    
    properties (Access = private)
        fileMenu
        experimentMenu
        protocolMenu
        toolsMenu
        helpMenu
        protocolDropDown
        protocolParameterGrid
        runButton
        pauseButton
        stopButton
        saveCheckbox
        statusText
    end
    
    methods
        
        function createUI(obj)
            import symphonyui.util.*;
            import symphonyui.util.ui.*;
            
            set(obj.figureHandle, 'Name', 'Symphony');
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
                'Accelerator', 't', ...
                'Separator', 'on');
            obj.experimentMenu.viewNotes = uimenu(obj.experimentMenu.root, ...
                'Label', 'View Notes');
            
            % Protocol menu.
            obj.protocolMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Protocol');
            obj.protocolMenu.presetsMenu.root = uimenu(obj.protocolMenu.root, ...
                'Label', 'Presets');
            obj.protocolMenu.presetsMenu.save = uimenu(obj.protocolMenu.presetsMenu.root, ...
                'Label', 'Save...');
            obj.protocolMenu.presetsMenu.export = uimenu(obj.protocolMenu.presetsMenu.root, ...
                'Label', 'Export...');
            obj.protocolMenu.run = uimenu(obj.protocolMenu.root, ...
                'Label', 'Run', ...
                'Accelerator', 'r', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Run'));
            obj.protocolMenu.pause = uimenu(obj.protocolMenu.root, ...
                'Label', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.protocolMenu.stop = uimenu(obj.protocolMenu.root, ...
                'Label', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));
            obj.protocolMenu.presetsMenu.default = uimenu(obj.protocolMenu.presetsMenu.root, ...
                'Label', 'Default', ...
                'Separator', 'on');
            obj.protocolMenu.presetsMenu.presets = [];
            
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
            obj.toolsMenu.preferences = uimenu(obj.toolsMenu.root, ...
                'Label', 'Preferences...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'Preferences'));
            
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
            
            iconsFolder = fullfile(mfilename('fullpath'), '..', '..', '..', 'Resources', 'Icons');
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
            obj.runButton = uicontrol( ...
                'Parent', layout, ...        
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'play.png'] '"/></html>'], ...
                'TooltipString', 'Run', ...
                'Callback', @(h,d)notify(obj, 'Run'));
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
            obj.saveCheckbox = uicontrol( ...
                'Parent', layout, ...
                'Style', 'checkbox', ...
                'String', 'Save', ...
                'HorizontalAlignment', 'right');
            set(layout, 'Sizes', [-1 44]);
            set(controlsLayout, 'Sizes', [-1 25]);
            
            
            set(mainLayout, 'Sizes', [25 -1 75]);
        end
        
        function close(obj)
            close@symphonyui.View(obj);
            obj.protocolParameterGrid.Close();
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
        
        function enableViewNotes(obj, tf)
            set(obj.experimentMenu.viewNotes, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableSelectRig(obj, tf)
            set(obj.toolsMenu.selectRig, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableViewRig(obj, tf)
            set(obj.toolsMenu.viewRig, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enablePreferences(obj, tf)
            set(obj.toolsMenu.preferences, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function enableSelectProtocol(obj, tf)
            set(obj.protocolDropDown, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function p = getProtocol(obj)
            p = symphonyui.util.ui.getSelectedValue(obj.protocolDropDown);
        end
        
        function setProtocol(obj, p)
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
            p = symphonyui.util.fieldsToParameters(properties);
        end
        
        function setProtocolParameters(obj, parameters)
            properties = symphonyui.util.parametersToFields(parameters);
            set(obj.protocolParameterGrid, 'Properties', properties);
        end
        
        function updateProtocolParameters(obj, parameters)
            properties = symphonyui.util.parametersToFields(parameters);
            obj.protocolParameterGrid.UpdateProperties(properties);
        end
        
        function enableProtocolPresets(obj, tf)
            set(obj.protocolMenu.presetsMenu.root, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function addProtocolPreset(obj, p)
            obj.protocolMenu.presetsMenu.presets(end + 1) = uimenu(obj.protocolMenu.presetsMenu.root, 'Label', p);
        end
        
        function clearProtocolPresets(obj)
            delete(obj.protocolMenu.presetsMenu.presets);
            obj.protocolMenu.presetsMenu.presets = [];
        end
        
        function enableRun(obj, tf)
            enable = symphonyui.util.onOff(tf);
            set(obj.protocolMenu.run, 'Enable', enable);
            set(obj.runButton, 'Enable', enable);
        end
        
        function enablePause(obj, tf)
            enable = symphonyui.util.onOff(tf);
            set(obj.protocolMenu.pause, 'Enable', enable);
            set(obj.pauseButton, 'Enable', enable);
        end
        
        function enableStop(obj, tf)
            enable = symphonyui.util.onOff(tf);
            set(obj.protocolMenu.stop, 'Enable', enable);
            set(obj.stopButton, 'Enable', enable);
        end
        
        function enableShouldSave(obj, tf)
            set(obj.saveCheckbox, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function tf = getShouldSave(obj)
            tf = get(obj.saveCheckbox, 'Value');
        end
        
        function setShouldSave(obj, tf)
            set(obj.saveCheckbox, 'Value', tf);
        end
        
        function enableStatus(obj, tf)
            set(obj.statusText, 'Enable', symphonyui.util.onOff(tf));
        end
        
        function setStatus(obj, s)
            set(obj.statusText, 'String', s);
        end
        
    end
    
end

