classdef SelectRigPresenter < symphonyui.Presenter
    
    properties (Access = private)
        controller
        rigMap
    end
    
    methods
        
        function obj = SelectRigPresenter(controller, view)
            if nargin < 2
                view = symphonyui.views.SelectRigView([]);
            end
            
            obj = obj@symphonyui.Presenter(view);
            
            obj.controller = controller;
            
            obj.addListener(controller, 'ChangedRigClassNames', @obj.onChangedRigClassNames);
            obj.addListener(controller, 'SelectedRig', @obj.onControllerSelectedRig);
            
            obj.addListener(view, 'Ok', @obj.onSelectedOk);
            obj.addListener(view, 'Cancel', @(h,d)obj.view.close);
        end
        
    end
    
    methods (Access = protected)
        
        function onViewShown(obj, ~, ~)            
            onViewShown@symphonyui.Presenter(obj);
            
            obj.view.setWindowKeyPressFcn(@obj.onWindowKeyPress);
            
            obj.onChangedRigClassNames();
            obj.onControllerSelectedRig();
        end
        
    end
    
    methods (Access = private)
        
        function onWindowKeyPress(obj, ~, data)
            if strcmp(data.Key, 'return')
                obj.onSelectedOK();
            elseif strcmp(data.Key, 'escape')
                obj.view.close();
            end
        end
        
        function onChangedRigClassNames(obj, ~, ~)
            % Create a set of display names for all available rigs.
            names = obj.controller.getRigClassNames;
            map = Map2();
            for i = 1:numel(names);
                className = names{i};
                displayName = symphonyui.util.classProperty(className, 'displayName');
                if isKey(map, displayName)
                    value = map(displayName);
                    map.remove(displayName);
                    map([displayName ' (' value ')']) = value;
                    displayName = [displayName ' (' className ')']; %#ok<AGROW>
                end
                map(displayName) = className;
            end
            
            obj.rigMap = map;
            obj.view.setRigList(obj.rigMap.keys);
        end
        
        function onControllerSelectedRig(obj, ~, ~)
            index = obj.rigMap.right_find(class(obj.controller.rig));
            key = obj.rigMap.right_at(index);
            obj.view.setRig(key);
        end
        
        function onSelectedOk(obj, ~, ~)
            drawnow();
            
            className = obj.rigMap(obj.view.getRig());
            
            try
                obj.controller.selectRigByClassName(className);
                obj.controller.rig.initialize();
            catch x
                symphonyui.presenters.MessageBoxPresenter.showException(x);
                warning(getReport(x));
                return;
            end
            
            obj.view.result = true;
        end
        
    end
    
end

