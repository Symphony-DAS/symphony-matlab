classdef ProtocolPresetsPresenter < appbox.Presenter
    
    properties (Access = private)
        acquisitionService
    end
    
    methods
        
        function obj = ProtocolPresetsPresenter(acquisitionService, view)
            if nargin < 2
                view = symphonyui.ui.views.ProtocolPresetsView();
            end
            obj = obj@appbox.Presenter(view);

            obj.acquisitionService = acquisitionService;
        end
        
    end
    
end

