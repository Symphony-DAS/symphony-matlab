classdef EpochGroupPreference < handle
    
    properties (SetObservable)
        labels = {''}
        recordingTypes = {''}
        availableExternalSolutions = {}
        availableInternalSolutions = {}
        availableOthers = {}
    end
    
    methods
        
        function setToDefaults(obj)
            obj.labels = { ...
                'Control', ...
                'Drug', ...
                'Wash'};
            
            obj.recordingTypes = { ...
                'Extracellular', ...
                'Whole-cell', ...
                'Suction'};
            
            obj.availableExternalSolutions = { ...
                'Ames Bicarb', ...
                'Ames Hepes', ...
                'NBQX-10mM', ...
                'TPMPA-50mM'};
            
            obj.availableInternalSolutions = { ...
                ''};
            
            obj.availableOthers = { ...
                ''};
        end
        
        function set.labels(obj, l)
            if ~iscell(l)
                error('Labels must be a cell array');
            end
            if isempty(l)
                error('Labels must not be empty');
            end
            obj.labels = l;
        end
        
        % TODO: Create setters.
        
    end
    
end

