classdef SettingsPresenter < symphonyui.ui.Presenter

    methods

        function obj = SettingsPresenter(app, view)
            if nargin < 2
                view = symphonyui.ui.views.SettingsView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
        end

    end

    methods (Access = protected)
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedNode', @obj.onViewSelectedNode);
            obj.addListener(v, 'Ok', @obj.onViewSelectedOk);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end

    methods (Access = private)

        function onViewKeyPress(obj, ~, event)
            switch event.key
                case 'return'
                    obj.onViewSelectedOk();
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedNode(obj, ~, ~)
            node = obj.view.getSelectedNode();
            list = obj.view.getCardList();
            index = find(strcmp(list, node));
            obj.view.setSelectedCard(index); %#ok<FNDSB>
        end

        function onViewSelectedOk(obj, ~, ~)
            obj.view.update();

            obj.view.hide();
        end

        function onViewSelectedCancel(obj, ~, ~)
            obj.view.hide();
        end

    end

end
