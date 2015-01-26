classdef MainView < symphonyui.View
    
    events
        NewExperiment
        CloseExperiment
        Exit
        BeginEpochGroup
        EndEpochGroup
        SelectedProtocol
        ProtocolParameters
        Run
        Pause
        Stop
        SetRig
        ViewRig
        Preferences
        Documentation
        UserGroup
        AboutSymphony
    end
    
    properties (Access = private)
        fileMenu
        experimentMenu
        acquisitionMenu
        toolsMenu
        helpMenu
        protocolDropDown
        protocolParametersButton
        runButton
        pauseButton
        stopButton
        saveCheckbox
        statusText
    end
    
    methods
        
        function createUI(obj)
            import symphonyui.utilities.*;
            import symphonyui.utilities.ui.*;
            
            set(obj.figureHandle, 'Name', 'Symphony');
            set(obj.figureHandle, 'Position', screenCenter(344, 136));
            
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
            
            % Acquisition menu.
            obj.acquisitionMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Acquisition');
            obj.acquisitionMenu.run = uimenu(obj.acquisitionMenu.root, ...
                'Label', 'Run', ...
                'Accelerator', 'r', ...
                'Callback', @(h,d)notify(obj, 'Run'));
            obj.acquisitionMenu.pause = uimenu(obj.acquisitionMenu.root, ...
                'Label', 'Pause', ...
                'Callback', @(h,d)notify(obj, 'Pause'));
            obj.acquisitionMenu.stop = uimenu(obj.acquisitionMenu.root, ...
                'Label', 'Stop', ...
                'Callback', @(h,d)notify(obj, 'Stop'));
            obj.acquisitionMenu.protocolParameters = uimenu(obj.acquisitionMenu.root, ...
                'Label', 'Protocol Parameters...', ...
                'Accelerator', 'e', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'ProtocolParameters'));
            
            % Tools menu.
            obj.toolsMenu.root = uimenu(obj.figureHandle, ...
                'Label', 'Tools');
            obj.toolsMenu.modulesMenu.root = uimenu(obj.toolsMenu.root, ...
                'Label', 'Modules');
            obj.toolsMenu.setRig = uimenu(obj.toolsMenu.root, ...
                'Label', 'Set Rig...', ...
                'Separator', 'on', ...
                'Callback', @(h,d)notify(obj, 'SetRig'));
            obj.toolsMenu.viewRig = uimenu(obj.toolsMenu.root, ...
                'Label', 'View Rig', ...
                'Callback', @(h,d)notify(obj, 'ViewRig'));
            obj.toolsMenu.options = uimenu(obj.toolsMenu.root, ...
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
                'Spacing', 3);
            
            % Protocol controls.
            layout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 3);
            obj.protocolDropDown = createDropDownMenu(layout, {''});
            set(obj.protocolDropDown, ...
                'TooltipString', 'Protocol', ...
                'Callback', @(h,d)notify(obj, 'SelectedProtocol'));
            obj.protocolParametersButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', ['<html><img src="' [iconsUrl 'list.png'] '"/></html>'], ...
                'TooltipString', 'Protocol Parameters...', ...
                'Callback', @(h,d)notify(obj, 'ProtocolParameters'));
            set(layout, 'Sizes', [-1 30]);
            
            % Run/Pause/Stop controls.
            layout = uiextras.HBox( ...
                'Parent', mainLayout, ...
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
            
            set(mainLayout, 'Sizes', [25 -1]);
            
            layout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'BackgroundColor', 'r');
            obj.saveCheckbox = uicontrol( ...
                'Parent', layout, ...
                'Style', 'checkbox', ...
                'String', 'Save');
            obj.statusText = createLabel(layout, 'Stopped');
            set(obj.statusText, 'HorizontalAlignment', 'right');
            set(layout, 'Sizes', [60 -1]);
            
            set(mainLayout, 'Sizes', [25 -1 25]);
        end
        
        function enableNewExperiment(obj, tf)
            set(obj.fileMenu.newExperiment, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableCloseExperiment(obj, tf)
            set(obj.fileMenu.closeExperiment, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableBeginEpochGroup(obj, tf)
            set(obj.experimentMenu.beginEpochGroup, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableEndEpochGroup(obj, tf)
            set(obj.experimentMenu.endEpochGroup, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableAddNote(obj, tf)
            set(obj.experimentMenu.addNote, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableViewNotes(obj, tf)
            set(obj.experimentMenu.viewNotes, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableSetRig(obj, tf)
            set(obj.toolsMenu.setRig, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableViewRig(obj, tf)
            set(obj.toolsMenu.viewRig, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableSelectProtocol(obj, tf)
            set(obj.protocolDropDown, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function enableProtocolParameters(obj, tf)
            enable = symphonyui.utilities.onOff(tf);
            set(obj.acquisitionMenu.protocolParameters, 'Enable', enable);
            set(obj.protocolParametersButton, 'Enable', enable);
        end
        
        function enableRun(obj, tf)
            enable = symphonyui.utilities.onOff(tf);
            set(obj.acquisitionMenu.run, 'Enable', enable);
            set(obj.runButton, 'Enable', enable);
        end
        
        function enablePause(obj, tf)
            enable = symphonyui.utilities.onOff(tf);
            set(obj.acquisitionMenu.pause, 'Enable', enable);
            set(obj.pauseButton, 'Enable', enable);
        end
        
        function enableStop(obj, tf)
            enable = symphonyui.utilities.onOff(tf);
            set(obj.acquisitionMenu.stop, 'Enable', enable);
            set(obj.stopButton, 'Enable', enable);
        end
        
        function p = getProtocol(obj)
            p = symphonyui.utilities.ui.getSelectedValue(obj.protocolDropDown);
        end
        
        function setProtocol(obj, p)
            symphonyui.utilities.ui.setSelectedValue(obj.protocolDropDown, p);
        end
        
        function setProtocolList(obj, p)
            symphonyui.utilities.ui.setStringList(obj.protocolDropDown, p);
        end
        
        function enableShouldSave(obj, tf)
            set(obj.saveCheckbox, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function tf = getShouldSave(obj)
            tf = get(obj.saveCheckbox, 'Value');
        end
        
        function setShouldSave(obj, tf)
            set(obj.saveCheckbox, 'Value', tf);
        end
        
        function enableStatus(obj, tf)
            set(obj.statusText, 'Enable', symphonyui.utilities.onOff(tf));
        end
        
        function setStatus(obj, s)
            set(obj.statusText, 'String', s);
        end
        
    end
    
end

