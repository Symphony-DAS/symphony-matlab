classdef ExperimentPreferences < handle
    
    properties (SetObservable)
        defaultName
        defaultPurpose
        defaultLocation
        speciesList
        phenotypeList
        genotypeList
        preparationList
    end
    
    methods
        
        function setToDefaults(obj)
            obj.defaultName = @()datestr(now, 'yyyy-mm-dd');
            obj.defaultLocation = @()pwd;
            obj.speciesList = { ...
                'C57BL/6', ...
                '???'};
            obj.phenotypeList = { ...
                'Wild Type', ...
                'Mutant'};
            obj.genotypeList = { ...
                'mGluR6-GFP', ...
                '???'};
            obj.preparationList = { ...
                'Whole Mount', ...
                'Slice'};
        end
        
        % TODO: Create setters.
        
    end
    
end

