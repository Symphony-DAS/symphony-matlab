classdef EpochGroupPreferences < handle
    
    properties (SetObservable)
        labelList
        recordingList
        defaultKeywords
        availableExternalSolutionList
        availableInternalSolutionList
        availableOtherList
    end
    
    methods
        
        function setToDefaults(obj)
            obj.labelList = { ...
                'Control', ...
                'Drug', ...
                'Wash'};
            obj.recordingList = { ...
                'Extracellular', ...
                'Whole-cell', ...
                'Suction'};
            obj.availableExternalSolutionList = { ...
                'Ames Bicarb', ...
                'Ames Hepes', ...
                'NBQX-10mM', ...
                'TPMPA-50mM'};
        end
        
        function set.labelList(obj, l)
            if ~iscell(l)
                error('Label list must be a cell array');
            end
            if isempty(l)
                error('Label list must not be empty');
            end
            obj.labelList = l;
        end
        
        % TODO: Create setters.
        
    end
    
end

