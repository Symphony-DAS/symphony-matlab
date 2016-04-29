function site()
    rootPath = fileparts(mfilename('fullpath'));
    sitePath = fullfile(rootPath, 'src', 'site');
    wikiPath = fullfile(sitePath, 'wiki');
    targetPath = fullfile(rootPath, 'target', 'site');
    [~, ~] = mkdir(targetPath);
    
    markdownFiles = dir(fullfile(wikiPath, '*.md'));
    for i = 1:length(markdownFiles)
        [~, name] = fileparts(markdownFiles(i).name);
        
        includeFile = fullfile(sitePath, 'include.html');
        inputFile = fullfile(wikiPath, [name '.md']);
        outputFile = fullfile(targetPath, [name '.html']);
        
        command = sprintf('pandoc -s --tab-stop=2 -H "%s" -c css/override.css -f markdown_github "%s" -o "%s"', includeFile, inputFile, outputFile);
        [status, out] = system(command);
        if status ~= 0
            error(out);
        end
        
        % Add page title.
        match = find(inputFile, '<!-- title: [\w.\- ]+ -->');
        if isempty(match)
            title = strrep(name, '-', ' ');
        else
            title = match{end}(13:end-4);
        end
        replace(outputFile, '<title></title>', sprintf('<title>%s</title>', title));
        
        match = find(inputFile, '<!-- description: [\w.\- ]+ -->');
        if isempty(match)
            description = '';
        else
            description = match{end}(19:end-4);
        end
        
        % Setup HTML to work better with doc center stylesheets.
        replace(outputFile, '<body>', ...
            ['<body>' ...
            '<div class="content_container" id="content_container">', ...
            '<div class="container-fluid">', ...
            '<div class="row">', ...
            '<div class="col-xs-12">', ...
            '<section id="doc_center_content" lang="en">', ...
            '<div id="pgtype-topic">', ...
            '<h1 itemprop="content title" class="r2016a">' title '</h1>', ...
            '<div class="doc_topic_desc" itemprop="content purpose">' description '</div>']);
        replace(outputFile, '</body>', '</div></section></div></div></div></div></body>');
        replace(outputFile, '<div class="sourceCode"><pre class="sourceCode matlab"><code class="sourceCode matlab">', '<div class="code_responsive"><div class="programlisting"><div class="codeinput"><pre><code>');
        replace(outputFile, '</code></pre></div>', '</code></pre></div></div>');
        
        % Add html extension to links with no extension.
        replace(outputFile, 'href="[\w.\-]+"', '${$0(1:end-1)}.html\"'); 
    end
    
    copyfile(fullfile(wikiPath, 'images'), fullfile(targetPath, 'images'));
    
    copyfile(fullfile(sitePath, 'info.xml'), fullfile(targetPath));
    copyfile(fullfile(sitePath, 'helptoc.xml'), fullfile(targetPath));
    copyfile(fullfile(sitePath, 'resources', 'css'), fullfile(targetPath, 'css'));
    
    % Build searchable database.
    addpath(genpath(fullfile(targetPath)));
    builddocsearchdb(fullfile(targetPath));
end

function match = find(file, expression)
    fid = fopen(file);
    text = fread(fid, inf, '*char')';
    fclose(fid);
    
    match = regexp(text, expression, 'match');
end

function replace(file, expression, replacement)
    fid = fopen(file);
    text = fread(fid, inf, '*char')';
    fclose(fid);
    
    text = regexprep(text, expression, replacement);
    
    fid = fopen(file, 'w');
    fwrite(fid, text);
    fclose(fid);
end