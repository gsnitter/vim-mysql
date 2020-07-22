let s:basePath = expand('<sfile>:p:h:h')
let s:insert = v:true

func! mysql#SetUpKeyMaps()
    let g:debug="SetupKeyMaps"
    nnoremap <buffer> <leader>l :call mysql#ListLoginPathes()<cr>
    nnoremap <buffer> <leader>d :call mysql#ListDatabases(v:false)<cr>
    nnoremap <buffer> <leader>t :call mysql#ListTables(v:false)<cr>

    inoremap <buffer> <leader>d <esc>:call mysql#ListDatabases(v:true)<cr>
    inoremap <buffer> <leader>t <esc>:call mysql#ListTables(v:true)<cr>
    inoremap <buffer> <leader>c <esc>:call mysql#ListColumns(v:true)<cr>

    vnoremap <buffer> M :call mysql#ExecuteQuery()<cr>
endfunc

func! mysql#LoadBufferVars()
    let g:mysqlSettings = eval(g:MysqlSettings)
    if has_key(g:mysqlSettings, expand("%:p"))
        if has_key(g:mysqlSettings[expand("%:p")], "loginPath")
            let b:loginPath=g:mysqlSettings[expand("%:p")]["loginPath"]
        endif
        if has_key(g:mysqlSettings[expand("%:p")], "database")
            let b:database=g:mysqlSettings[expand("%:p")]["database"]
        endif
        if has_key(g:mysqlSettings[expand("%:p")], "table")
            let b:table=g:mysqlSettings[expand("%:p")]["table"]
        endif
    endif
endfunc

func! mysql#ListLoginPathes()
    let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:80%' --layout reverse"
    let previewCommand = 'mysql_config_editor print --login-path={}'
    if system("type grc 2> /dev/null 1> /dev/null; echo $?")==0
        let previewCommand = previewCommand . ' | grcat ' . s:basePath . '/bin/grcat_config2'
    endif
    let previewCommand = previewCommand . ' && echo && echo ------ && echo && mysql_config_editor print --all'
    if system("type grc 2> /dev/null 1> /dev/null; echo $?")==0
        let previewCommand = previewCommand . ' | grcat ' . s:basePath . '/bin/grcat_config2'
    endif
    call fzf#run({"source": s:basePath . '/bin/ls_mysql_config_editor_login_pathes', "sink": "MySQLSetLoginPath", "window": {"width": 0.9, "height": 0.9}, "options": ["--preview", previewCommand]})

endfunc

func! mysql#SetLoginPath(path)
    let b:loginPath = a:path
    if !has_key(g:mysqlSettings, expand("%:p"))
        let g:mysqlSettings[expand("%:p")] = {}
    endif
    let g:mysqlSettings[expand("%:p")]['loginPath'] = a:path
    let g:MysqlSettings = string(g:mysqlSettings)
endfunc

func! mysql#ListDatabases(insert)
    let s:insert = a:insert

    if exists("b:loginPath")
        let result = system(s:basePath . '/bin/ls_databases ' . b:loginPath)
        if v:shell_error
            call mysql#displayError("Login-Path " . b:loginPath . " failed: " . result)
            return
        endif

        let previewCommand = s:basePath . '/bin/desc_database ' . b:loginPath . ' {}'
        if system("type grc 2> /dev/null 1> /dev/null; echo $?")==0
            let previewCommand = previewCommand . ' | grcat ' . s:basePath . '/bin/grcat_config'
        endif
        let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:80%' --layout reverse"
        call fzf#run({"source": s:basePath . '/bin/ls_databases ' . b:loginPath, "sink": "MySQLSetDatabase", "window": {"width": 0.9, "height": 0.9}, "options": ["--preview", previewCommand]})
    else
        call mysql#displayError("No login path selected")
    endif
endfunc

func! mysql#ListTables(insert)
    let s:insert = a:insert

    if exists("b:database")
        let result = system(s:basePath . '/bin/ls_tables ' . b:loginPath . ' ' . b:database)
        if v:shell_error
            call mysql#displayError("Failed to list tables for database" . b:database .  " and Login-Path " . b:loginPath: " . result)
            return
        endif

        let previewCommand = s:basePath . '/bin/desc_table ' . b:loginPath . ' ' . b:database . ' {}'
        if system("type grc 2> /dev/null 1> /dev/null; echo $?")==0
            let previewCommand = previewCommand . ' | grcat ' . s:basePath . '/bin/grcat_config'
        endif
        let $FZF_DEFAULT_OPTS="--ansi --preview-window 'right:80%' --layout reverse"
        call fzf#run({"source": s:basePath . '/bin/ls_tables ' . b:loginPath . ' ' . b:database, "sink": "MySQLSetTable", "window": {"width": 0.9, "height": 0.9}, "options": ["--preview", previewCommand]})
    else
        call mysql#displayError("No database selected")
    endif
endfunc

func! mysql#ListColumns(insert)
    let s:insert = a:insert

    if exists("b:table")
        let result = system(s:basePath . '/bin/ls_columns ' . b:loginPath . ' ' . b:database . ' ' . b:table)
        if v:shell_error
            call mysql#displayError("Failed to list columns for table " . b:table . " in database " . b:database .  " with Login-Path " . b:loginPath: " . result)
            return
        endif

        let previewCommand = s:basePath . '/bin/desc_column ' . b:loginPath . ' ' . b:database . ' ' . b:table . ' {}'
        if system("type grc 2> /dev/null 1> /dev/null; echo $?")==0
            let previewCommand = previewCommand . ' | grcat ' . s:basePath . '/bin/grcat_config'
        endif

        call fzf#run({"source": s:basePath . '/bin/ls_columns ' . b:loginPath . ' ' . b:database . ' ' . b:table, "sink": "MySQLSetColumn", "window": {"width": 0.9, "height": 0.9}, "options": ["--preview", previewCommand]})

    else
        call mysql#displayError("No database selected")
    endif
endfunc

func! mysql#SetDatabase(database)
    let b:database = a:database
    let g:mysqlSettings[expand("%:p")]['database'] = a:database
    let g:MysqlSettings = string(g:mysqlSettings)
    call mysql#insert(a:database)
endfunc

func! mysql#SetTable(table)
    let b:table = a:table
    let g:mysqlSettings[expand("%:p")]['table'] = a:table
    let g:MysqlSettings = string(g:mysqlSettings)
    call mysql#insert(a:table)
endfunc

func! mysql#SetColumn(column)
    call mysql#insert(a:column)
endfunc

func! mysql#insert(text)
    if s:insert
        exec("normal a" . a:text)
        if getpos(".")[2] >= strlen(getline("."))
            startinsert!
        else
            normal l
            startinsert
        endif
    endif
endfunc

func! mysql#displayError(message)
    if exists('*popup_notification')
        let winid=popup_notification(a:message, #{ line: 5, col: 10, highlight: 'WarningMsg', title: '', time: 5000, maxheight: 10} )
        hi MyPopupColor ctermbg=red guibg=red
        call setwinvar(winid, '&wincolor', 'MyPopupColor')
    else
        echo a:message
    endif
endfunc

func! mysql#ExecuteQuery() range
    if !exists("b:database")
        call mysql#displayError("No database selected")
        return
    endif

    " Prepare the query
    :write
    let l:queryCommand = ".!cat " . expand("%:p") . ' | awk "NR >= ' . a:firstline . ' && NR <= ' . a:lastline . '"'
    let l:queryCommand = l:queryCommand . " | mysql --login-path=" . b:loginPath . ' --database=' . b:database . ' --table'

    " Close old buffer and open a new one below
    silent! bdelete! mysql_result
    execute "sp mysql_result"
    exe "normal \<c-w>J"
    exe "setlocal buftype=nofile modifiable"

    " :highlight mysqlTableBorder ctermbg=darkred guibg=red ctermfg=black guifg=black
    :highlight mysqlDefault ctermfg=green guifg=green
    :call matchadd('mysqlDefault', '.*', 0)
    :highlight mysqlTableBorder ctermfg=red guifg=red
    call matchadd('mysqlTableBorder',  '\(^[+-]\+$\)\|^[|]\| | \| |$')
    :highlight mysqlDefinition ctermfg=white guifg=white
    call matchadd('mysqlDefinition',  '^\s*\w\+:')
    call matchadd('mysqlDefinition',  '^\*\+')
    call matchadd('mysqlDefinition', '\%2l\w\+', 20)

    " Execute query inside new buffer and return
    exe l:queryCommand
    exe "normal \<c-w>k"
endfunc
