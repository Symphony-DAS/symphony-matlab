classdef PersistorTest < symphonyui.TestBase

    properties
        persistor
    end

    properties (Constant)
        TEST_FILE = 'test.h5'
        TEST_START_TIME = datetime([2016,10,24,11,45,07], 'TimeZone', 'America/Denver');
        TEST_END_TIME = datetime([2016,10,24,12,48,32], 'TimeZone', 'Asia/Tokyo');
        TEST_PARAMETERS = containers.Map({'one', 'two', 'three'}, {1, 2.222, 'three'});
    end

    methods (TestMethodSetup)

        function methodSetup(obj)
            cobj = Symphony.Core.H5EpochPersistor.Create(obj.TEST_FILE);
            obj.persistor = symphonyui.core.Persistor.newPersistor(cobj, symphonyui.core.persistent.descriptions.ExperimentDescription());
        end

    end

    methods (TestMethodTeardown)

        function methodTeardown(obj)
            try %#ok<TRYNC>
                obj.persistor.close();
            end
            if exist(obj.TEST_FILE, 'file')
                delete(obj.TEST_FILE);
            end
        end

    end

    methods (Test)

        function testEntityProperties(obj)
            entity = obj.persistor.experiment;

            expected = containers.Map();
            expected('uint16') = uint16(12);
            expected('uint16v') = uint16([1 2 3 4 5]);
            expected('uint16m') = uint16([1 2 3; 4 5 6; 7 8 9]);
            expected('double') = 3.5;
            expected('doublev') = [1 2 3 4];
            expected('doublem') = [1 2 3; 4 5 6; 7 8 9];
            expected('string') = 'hello world!';

            keys = expected.keys;
            for i = 1:numel(keys)
                entity.addProperty(keys{i}, expected(keys{i}));
            end

            obj.verifyEqual(entity.getPropertyDescriptors.toMap(), expected);
        end

        function testEntityKeywords(obj)
            entity = obj.persistor.experiment;

            expected = {'zam', 'pow', 'taco!', '_+zoooom'};

            for i = 1:numel(expected)
                entity.addKeyword(expected{i});
            end

            obj.verifyEqual(entity.keywords, expected);
        end

        function testEntityNotes(obj)
            entity = obj.persistor.experiment;

            time1 = datetime('now', 'TimeZone', 'America/Denver');
            text1 = 'Hi, this is a note about this entity and it is cool';
            entity.addNote(text1, time1);

            time2 = datetime('now', 'TimeZone', 'Africa/Johannesburg');
            text2 = 'Hello from Africa!';
            entity.addNote(text2, time2);

            note1 = entity.notes{1};
            obj.verifyDatetimesEqual(note1.time, time1);
            obj.verifyEqual(note1.text, text1);

            note2 = entity.notes{2};
            obj.verifyDatetimesEqual(note2.time, time2);
            obj.verifyEqual(note2.text, text2);
        end

        function testDevice(obj)
            dev = obj.persistor.addDevice('dev', 'man');

            obj.verifyEqual(dev.name, 'dev');
            obj.verifyEqual(dev.manufacturer, 'man');
            obj.verifyEqual(dev.experiment, obj.persistor.experiment);
        end

        function testSource(obj)
            src = obj.persistor.addSource([], 'src');

            obj.verifyEqual(src.label, 'src');
            obj.verifyEmpty(src.sources);
            obj.verifyEmpty(src.allSources);
            obj.verifyEmpty(src.epochGroups);
            obj.verifyEmpty(src.allEpochGroups);
            obj.verifyEmpty(src.parent);
            obj.verifyEqual(src.experiment, obj.persistor.experiment);

            src1 = obj.persistor.addSource(src, 'src1');
            src2 = obj.persistor.addSource(src, 'src2');
            src3 = obj.persistor.addSource(src2, 'src3');

            obj.verifyEqual(src1.parent, src);
            obj.verifyEqual(src2.parent, src);
            obj.verifyEqual(src3.parent, src2);
            obj.verifyCellsAreEquivalent(src.sources, {src1, src2});
            obj.verifyCellsAreEquivalent(src.allSources, {src1, src2, src3});

            grp1 = obj.persistor.beginEpochGroup(src, 'grp1');
            grp2 = obj.persistor.beginEpochGroup(src, 'grp2');
            grp3 = obj.persistor.beginEpochGroup(src1, 'grp3');

            obj.verifyCellsAreEquivalent(src.epochGroups, {grp1, grp2});
            obj.verifyCellsAreEquivalent(src.allEpochGroups, {grp1, grp2, grp3});
        end

        function testExperiment(obj)
            exp = obj.persistor.experiment;

            obj.verifyEmpty(exp.purpose);
            obj.verifyEmpty(exp.devices);
            obj.verifyEmpty(exp.sources);
            obj.verifyEmpty(exp.allSources);
            obj.verifyEmpty(exp.epochGroups);
            obj.verifyEmpty(exp.allEpochGroups);

            dev1 = obj.persistor.addDevice('dev1', 'man1');
            dev2 = obj.persistor.addDevice('dev2', 'man2');

            obj.verifyCellsAreEquivalent(exp.devices, {dev1, dev2});

            src1 = obj.persistor.addSource([], 'src1');
            src2 = obj.persistor.addSource([], 'src2');
            src3 = obj.persistor.addSource(src1, 'src3');

            obj.verifyCellsAreEquivalent(exp.sources, {src1, src2});
            obj.verifyCellsAreEquivalent(exp.allSources, {src1, src2, src3});

            grp1 = obj.persistor.beginEpochGroup(src1, 'grp1');
            obj.persistor.endEpochGroup();
            grp2 = obj.persistor.beginEpochGroup(src2, 'grp2');
            grp3 = obj.persistor.beginEpochGroup(src2, 'grp3');

            obj.verifyCellsAreEquivalent(exp.epochGroups, {grp1, grp2});
            obj.verifyCellsAreEquivalent(exp.allEpochGroups, {grp1, grp2, grp3});
        end

        function testEpochGroup(obj)
            obj.verifyEmpty(obj.persistor.currentEpochGroup);

            src = obj.persistor.addSource([], 'src');
            grp = obj.persistor.beginEpochGroup(src, 'grp');

            obj.verifyEqual(obj.persistor.currentEpochGroup, grp);
            obj.verifyEqual(grp.label, 'grp');
            obj.verifyEqual(grp.source, src);
            obj.verifyEmpty(grp.epochGroups);
            obj.verifyEmpty(grp.epochBlocks);
            obj.verifyEmpty(grp.parent);
            obj.verifyEqual(grp.experiment, obj.persistor.experiment);

            grp1 = obj.persistor.beginEpochGroup(src, 'grp1');
            obj.persistor.endEpochGroup();
            grp2 = obj.persistor.beginEpochGroup(src, 'grp2');
            grp3 = obj.persistor.beginEpochGroup(src, 'grp3');
            obj.persistor.endEpochGroup();
            obj.persistor.endEpochGroup();

            obj.verifyEqual(grp1.parent, grp);
            obj.verifyEqual(grp2.parent, grp);
            obj.verifyEqual(grp3.parent, grp2);
            obj.verifyCellsAreEquivalent(grp.epochGroups, {grp1, grp2});
            obj.verifyCellsAreEquivalent(grp.allEpochGroups, {grp1, grp2, grp3});

            blk1 = obj.persistor.beginEpochBlock('blk1', obj.TEST_PARAMETERS);
            obj.persistor.endEpochBlock();
            blk2 = obj.persistor.beginEpochBlock('blk2', obj.TEST_PARAMETERS);

            obj.verifyCellsAreEquivalent(grp.epochBlocks, {blk1, blk2});
        end

        function testEpochBlock(obj)
            obj.verifyEmpty(obj.persistor.currentEpochBlock);

            src = obj.persistor.addSource([], 'src');
            grp = obj.persistor.beginEpochGroup(src, 'grp');
            blk = obj.persistor.beginEpochBlock('blk', obj.TEST_PARAMETERS);

            obj.verifyEqual(obj.persistor.currentEpochBlock, blk);
            obj.verifyEqual(blk.protocolId, 'blk');
            obj.verifyEqual(blk.protocolParameters, obj.TEST_PARAMETERS);
            obj.verifyEmpty(blk.epochs);
            obj.verifyEqual(blk.epochGroup, grp);
            obj.verifyEmpty(blk.endTime);
        end

    end

end
