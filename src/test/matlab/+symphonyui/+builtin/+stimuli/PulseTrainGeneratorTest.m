classdef PulseTrainGeneratorTest < symphonyui.builtin.StimulusGeneratorTestBase
    
    properties
        generator
    end
    
    methods (TestMethodSetup)
        
        function methodSetup(obj)
            gen = symphonyui.builtin.stimuli.PulseTrainGenerator();
            gen.preTime = 50;
            gen.pulseTime = 100;
            gen.intervalTime = 20;
            gen.tailTime = 70;
            gen.amplitude = 120;
            gen.mean = -30;
            gen.numPulses = 3;
            gen.pulseTimeIncrement = 1;
            gen.intervalTimeIncrement = 2;
            gen.amplitudeIncrement = 3;
            gen.sampleRate = 200;
            gen.units = 'units';
            obj.generator = gen;
        end
        
    end
    
    methods (Test)
        
        function testGenerate(obj)
            import matlab.unittest.constraints.*;
            
            gen = obj.generator;
            stim = gen.generate();
            
            obj.verifyEqual(stim.sampleRate.quantityInBaseUnits, gen.sampleRate);
            obj.verifyEqual(stim.sampleRate.baseUnits, 'Hz');
            obj.verifyEqual(stim.units, gen.units);
            
            timeToPts = @(t)(round(t / 1e3 * gen.sampleRate));
            
            [q, u] = stim.getData();
            
            prePts = timeToPts(gen.preTime);
            preData = q(1:prePts);
            remainingData = q(prePts+1:end);
            
            obj.verifyEveryDoubleElementEqualTo(preData, gen.mean);
            
            for i = 0:gen.numPulses-1
                pulsePts = timeToPts(gen.pulseTimeIncrement * i + gen.pulseTime);                
                pulseData = remainingData(1:pulsePts);
                remainingData = remainingData(pulsePts+1:end);
                
                obj.verifyEveryDoubleElementEqualTo(pulseData, gen.mean + gen.amplitude + gen.amplitudeIncrement * i);
                
                if i < gen.numPulses-1
                    intervalPts = timeToPts(gen.intervalTimeIncrement * i + gen.intervalTime);
                    intervalData = remainingData(1:intervalPts);
                    remainingData = remainingData(intervalPts+1:end);
                    
                    obj.verifyEveryDoubleElementEqualTo(intervalData, gen.mean);
                end
            end
            
            tailPts = timeToPts(gen.tailTime);
            tail = remainingData(1:tailPts);
            remainingData = remainingData(tailPts+1:end);
            
            obj.verifyEveryDoubleElementEqualTo(tail, gen.mean);
            obj.verifyEqual(length(remainingData), 0);
            obj.verifyEqual(u, gen.units);
        end
        
        function testRegenerate(obj)
            stim = obj.generator.generate();
            obj.verifyStimulusRegenerates(stim);
        end
        
    end
    
end

