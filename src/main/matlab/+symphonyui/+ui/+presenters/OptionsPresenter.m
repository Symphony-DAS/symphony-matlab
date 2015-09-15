classdef OptionsPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        configurationService
    end
    
    methods

        function obj = OptionsPresenter(configurationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.OptionsView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.view.setWindowStyle('modal');
            
            obj.configurationService = configurationService;
        end

    end

    methods (Access = protected)
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            obj.addListener(v, 'Apply', @obj.onViewSelectedApply);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedApply();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedNode(obj, ~, ~)
            disp('Selected node');
        end

        function onViewSelectedApply(obj, ~, ~)
            obj.view.update();

            obj.view.close();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.view.close();
        end

    end

end
