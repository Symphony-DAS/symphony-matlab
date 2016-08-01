function site()
    rootPath = fileparts(mfilename('fullpath'));
    sitePath = fullfile(rootPath, 'src', 'site');
    docsPath = fullfile(sitePath, 'docs');
    targetPath = fullfile(rootPath, 'target', 'site');
    [~, ~] = mkdir(targetPath);
    
    markdownFiles = dir(fullfile(docsPath, '*.md'));
    for i = 1:length(markdownFiles)
        [~, name] = fileparts(markdownFiles(i).name);
        
        includeFile = fullfile(sitePath, 'include.html');
        inputFile = fullfile(docsPath, [name '.md']);
        outputFile = fullfile(targetPath, [name '.html']);
        
        command = sprintf('pandoc -s --tab-stop=2 -H "%s" -c css/override.css -f markdown_github "%s" -o "%s"', includeFile, inputFile, outputFile);
        [status, out] = system(command);
        if status ~= 0
            error(out);
        end
        
        % Front matter.
        match = find(inputFile, '^---(\r\n|\r|\n)(.*?)(\r\n|\r|\n)---(\r\n|\r|\n)');
        if isempty(match)
            description = '';
        else
            d = regexp(match{1}, 'description:[\w.\- ]+', 'match', 'once');
            description = strtrim(d(13:end));
            replace(outputFile, '<hr />(.*?)</h2>', '', 'once');
        end

        % Move first H1 heading to title.
        match = find(inputFile, '#[\w.\- ]+');
        if isempty(match)
            title = strrep(name, '-', ' ');
        else
            title = strtrim(match{1}(2:end));
            replace(outputFile, ['<h1 id="[\w.\- ]+">' title '</h1>'], '', 'once');
        end
        replace(outputFile, '<title></title>', sprintf('<title>%s</title>', title), 'once');
        
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
        replace(outputFile, '</code></pre></div>', '</code></pre></div></div></div>');
        replace(outputFile, '<h[0-9] id="[\w.\- ]+"', '<a class="anchor" id="${$0(9:end-1)}"></a>$0');
        
        % Replace markdown links with html links.
        replace(outputFile, 'href="[\w.\-]+.md"', '${$0(1:end-4)}.html\"');
    end
    
    copyfile(fullfile(docsPath, 'images'), fullfile(targetPath, 'images'));
    
    copyfile(fullfile(sitePath, 'info.xml'), fullfile(targetPath));
    copyfile(fullfile(sitePath, 'helptoc.xml'), fullfile(targetPath));
    copyfile(fullfile(sitePath, 'resources', 'css'), fullfile(targetPath, 'css'));
    
    % Exclude unnecessary files.
    delete(fullfile(targetPath, 'images', 'file-format', 'file-format.bmpr'));
    delete(fullfile(targetPath, 'images', 'standard-stimulus-generators', 'intaglio-figures.zip'));
    
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

function replace(file, expression, replacement, opts)
    if nargin < 4
        opts = {};
    end
    if ~iscell(opts)
        opts = {opts};
    end

    fid = fopen(file);
    text = fread(fid, inf, '*char')';
    fclose(fid);

    text = regexprep(text, expression, replacement, opts{:});

    fid = fopen(file, 'w');
    fwrite(fid, text);
    fclose(fid);
end
