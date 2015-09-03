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
            obj.createPreview();
        end

        function onBind(obj)
            a = obj.acquisitionService;
            obj.addListener(a, 'SelectedProtocol', @obj.onServiceSelectedProtocol);
            obj.addListener(a, 'SetProtocolProperty', @obj.onServiceSetProtocolProperty);
        end

    end

    methods (Access = private)
        
        function onServiceSelectedProtocol(obj, ~, ~)
            obj.createPreview();
        end
        
        function createPreview(obj)
            className = obj.acquisitionService.getSelectedProtocol();
            obj.view.setTitle([className ' Preview']);
            
            panel = obj.view.getPreviewPanel();
            delete(get(panel, 'Children'));
            set(panel, 'UserData', []);
            obj.acquisitionService.createProtocolPreview(panel);
        end
        
        function onServiceSetProtocolProperty(obj, ~, ~)
            obj.updatePreview();
        end
        
        function updatePreview(obj)
            panel = obj.view.getPreviewPanel();
            obj.acquisitionService.updateProtocolPreview(panel);
        end
        
    end

end
