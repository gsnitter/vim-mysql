" TODO SNI: Nur zum Entwickeln
autocmd! BufWritePost /home/snitter/.vim/pack/sni/start/mysql/autoload/mysql.vim source /home/snitter/.vim/pack/sni/start/mysql/autoload/mysql.vim

let s:basePath = expand('<sfile>:p:h:h')
let s:insert = v:true

func! mysql#ListLoginPathes()
    call fzf#run({"source": s:basePath . '/bin/ls_mysql_config_editor_login_pathes', "sink": "MySQLSetLoginPath", "options": "--no-preview"})
endfunc

func! mysql#SetLoginPath(path)
    let b:loginPath = a:path
endfunc

func! mysql#ListDatabases(insert)
    let s:insert = a:insert

    if exists("b:loginPath")
        let result = system(s:basePath . '/bin/ls_databases ' . b:loginPath)
        if v:shell_error
            call mysql#displayError("Login-Path " . b:loginPath . " failed: " . result)
            return
        endif
        call fzf#run({"source": s:basePath . '/bin/ls_databases ' . b:loginPath, "sink": "MySQLSetDatabase", "options": ["--preview", s:basePath . '/bin/ls_tables ' . b:loginPath . ' {}']})
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
        call fzf#run({"source": s:basePath . '/bin/ls_tables ' . b:loginPath . ' ' . b:database, "sink": "MySQLSetTable", "options": ["--preview", s:basePath . '/bin/ls_columns ' . b:loginPath . ' ' . b:database . ' {}']})
    else
        call mysql#displayError("No database selected")
    endif
endfunc

func! mysql#ListColumns(insert)
    let s:insert = a:insert

    if exists("b:table")
        let result = system(s:basePath . '/bin/ls_columns ' . b:loginPath . ' ' . b:database . ' ' . b.table)
        if v:shell_error
            call mysql#displayError("Failed to list columns for table " . b:table . " in database" . b:database .  " with Login-Path " . b:loginPath: " . result)
            return
        endif
        call fzf#run({"source": s:basePath . '/bin/ls_columns ' . b:loginPath . ' ' . b:database . ' ' . b:table, "sink": "MySQLSetColumn", "options": "--no-preview"})
    else
        call mysql#displayError("No database selected")
    endif
endfunc

func! mysql#SetDatabase(database)
    let b:database = a:database
    call mysql#insert(a:database)
endfunc

func! mysql#SetTable(table)
    let b:table = a:table
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
    let winid=popup_notification(a:message, #{ line: 5, col: 10, highlight: 'WarningMsg', title: '', time: 20000, maxheight: 10} )
    hi MyPopupColor ctermbg=red guibg=red
    call setwinvar(winid, '&wincolor', 'MyPopupColor')
endfunc
