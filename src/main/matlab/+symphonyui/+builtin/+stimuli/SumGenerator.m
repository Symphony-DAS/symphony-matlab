classdef SumGenerator < symphonyui.core.StimulusGenerator
    % Generates a stimulus from the sum of a set of specified stimuli. All stimuli must have the same duration, units 
    % and sample rate.

    properties
        stimuli     % Cell array of stimuli to sum
    end

    methods

        function obj = SumGenerator(map)
            if nargin < 1
                map = containers.Map();
            end

            if ~map.isKey('stimuli')
                % Rebuild stimuli from given parameters.

                keys = map.keys;

                paramMaps = {};
                for i = 1:length(keys)
                    key = keys{i};

                    if ~strcmp(key(1:4), 'stim')
                        continue;
                    end

                    split = regexp(key, '_', 'split', 'once');
                    stimName = split{1};
                    stimParam = split{2};

                    stimNum = str2double(stimName(5:end));
                    if isnan(stimNum)
                        error('Error while parsing parameters struct');
                    end

                    if numel(paramMaps) < stimNum + 1 || isempty(paramMaps{stimNum + 1})
                        paramMaps{stimNum + 1} = containers.Map(); %#ok<AGROW>
                    end
                    paramMaps{stimNum + 1}(stimParam) = map(key); %#ok<AGROW>
                    map.remove(key);
                end

                stims = {};
                for i = 1:length(paramMaps)
                    paramMap = paramMaps{i};

                    if ~paramMap.isKey('stimulusID')
                        error('Stimulus parameters is missing ''stimulusID''');
                    end
                    id = paramMap('stimulusID');
                    paramMap = paramMap.remove('stimulusID');

                    constructor = str2func(id);

                    gen = constructor(paramMap);
                    stims{end + 1} = gen.generate(); %#ok<AGROW>
                end

                map('stimuli') = stims;
            end

            obj@symphonyui.core.StimulusGenerator(map);
        end

    end

    methods (Access = protected)

        function s = generateStimulus(obj)
            import Symphony.Core.*;

            stimList = NET.createGeneric('System.Collections.Generic.List', {'Symphony.Core.IStimulus'});
            for i = 1:length(obj.stimuli)
                stimList.Add(obj.stimuli{i}.cobj);
            end

            map = obj.propertyMap;
            map.remove('stimuli');
            parameters = obj.dictionaryFromMap(map);

            cobj = CombinedStimulus(class(obj), parameters, stimList, CombinedStimulus.Add);
            s = symphonyui.core.Stimulus(cobj);
        end

    end

end
