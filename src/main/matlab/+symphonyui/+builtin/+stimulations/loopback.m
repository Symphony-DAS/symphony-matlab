function inputMap = loopback(daq, outputMap, timeStep)
    % Returns all stimuli on output channels as responses on corresponding input channels (e.g. a stimulus on ao1 will 
    % return as a response on ai1). Noise is simulated for input channels with no corresponding output channel.

    inputMap = containers.Map();
    
    % Loop through all input streams.
    inputStreams = daq.getInputStreams();
    for i = 1:numel(inputStreams)
        inStream = inputStreams{i};
        inData = [];
        
        if ~inStream.active
            % We don't care to process inactive input streams (i.e. channels without devices).
            continue;
        end
        
        % If there is a corresponding output data, make it into input data.
        outData = [];
        if outputMap.isKey(strrep(inStream.name, 'ai', 'ao'))
            outData = outputMap(strrep(inStream.name, 'ai', 'ao'));
        elseif outputMap.isKey(strrep(inStream.name, 'diport', 'doport'))
            outData = outputMap(strrep(inStream.name, 'diport', 'doport'));
        end
        if ~isempty(outData)
            [quantities, units] = outData.getData();
            rate = outData.sampleRate;
            inData = symphonyui.core.InputData(quantities, units, rate);
        end
        
        % If there is no corresponding output data, simulate noise.
        if isempty(inData)
            rate = inStream.sampleRate;
            nsamples = seconds(timeStep) * rate.quantityInBaseUnits;
            if strncmp(inStream.name, 'diport', 6)
                % Digital noise.
                quantities = randi(2^16-1, 1, nsamples);
            else
                % Analog noise.
                quantities = rand(1, nsamples) - 0.5;
            end
            units = inStream.measurementConversionTarget;
            inData = symphonyui.core.InputData(quantities, units, rate);
        end
        
        inputMap(inStream.name) = inData;
    end
end
