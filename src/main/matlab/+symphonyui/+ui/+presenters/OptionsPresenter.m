classdef OptionsPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        configurationService
    end

    methods

        function obj = OptionsPresenter(configurationService, view)
            if nargin < 2
                view = symphonyui.ui.views.OptionsView();
            end
            obj = obj@symphonyui.ui.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.configurationService = configurationService;
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateDetails();
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            obj.addListener(v, 'Apply', @obj.onViewSelectedApply);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function populateDetails(obj)

        end

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    obj.onViewSelectedApply();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedNode(obj, ~, ~)
            index = obj.view.getSelectedNode();
            obj.view.setCardSelection(index);
        end

        function onViewSelectedApply(obj, ~, ~)
            obj.view.update();



            obj.stop();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end

    end

end
