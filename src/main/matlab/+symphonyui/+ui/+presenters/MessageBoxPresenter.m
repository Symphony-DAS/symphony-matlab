classdef MessageBoxPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        text
        title
        button1
        button2
        button3
        default
    end

    methods

        function obj = MessageBoxPresenter(text, title, button1, button2, button3, default, view)
            if nargin < 7
                view = symphonyui.ui.views.MessageBoxView();
            end
            obj = obj@symphonyui.ui.Presenter(view);
            obj.view.setWindowStyle('modal');

            obj.text = text;
            obj.title = title;
            obj.button1 = button1;
            obj.button2 = button2;
            obj.button3 = button3;
            obj.default = default;
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.view.setText(obj.text);
            obj.view.setTitle(obj.title);
            obj.view.setButton1(obj.button1);
            obj.view.setButton2(obj.button2);
            obj.view.setButton3(obj.button3);
            obj.view.setButton1Visible(~isempty(obj.button1));
            obj.view.setButton2Visible(~isempty(obj.button2));
            obj.view.setButton3Visible(~isempty(obj.button3));
            if obj.default == 1
                obj.view.setButton1Default();
            elseif obj.default == 2
                obj.view.setButton2Default();
            elseif obj.default == 3
                obj.view.setButton3Default();
            end
        end

        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'Button1', @obj.onViewSelectedButton1);
            obj.addListener(v, 'Button2', @obj.onViewSelectedButton2);
            obj.addListener(v, 'Button3', @obj.onViewSelectedButton3);
        end

    end

    methods (Access = private)

        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    if obj.default == 1
                        obj.onViewSelectedButton1();
                    elseif obj.default == 2
                        obj.onViewSelectedButton2();
                    elseif obj.default == 3
                        obj.onViewSelectedButton3();
                    end
                case 'escape'
                    obj.stop();
            end
        end

        function onViewSelectedButton1(obj, ~, ~)
            obj.result = obj.button1;
            obj.stop();
        end

        function onViewSelectedButton2(obj, ~, ~)
            obj.result = obj.button2;
            obj.stop();
        end

        function onViewSelectedButton3(obj, ~, ~)
            obj.result = obj.button3;
            obj.stop();
        end

    end

end
