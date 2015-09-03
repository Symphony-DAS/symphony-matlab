classdef ProtocolPreviewPresenter < symphonyui.ui.Presenter

    properties (Access = private)
        acquisitionService
    end

    methods

        function obj = ProtocolPreviewPresenter(acquisitionService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.ProtocolPreviewView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);

            obj.acquisitionService = acquisitionService;
        end

    end

    methods (Access = protected)

        function onGoing(obj)
        end

        function onBind(obj)
            a = obj.acquisitionService;
            obj.addListener(a, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
            obj.addListener(a, 'SetProtocolProperty', @obj.onServiceSetProtocolProperty);
        end

    end

    methods (Access = private)
        
        function onServiceSelectedProtocol(obj, ~, ~)
            disp('Selected protocol');
        end
        
        function onServiceSetProtocolProperty(obj, ~, ~)
            disp('Set protocol property');
        end
        
    end

end
