if !exists("g:MysqlSettings")
    let g:MysqlSettings=string({})
endif

:autocmd FileType sql call mysql#SetUpKeyMaps()
:autocmd FileType sql call mysql#LoadBufferVars()

:command! -nargs=1 MySQLSetLoginPath :call mysql#SetLoginPath("<args>")
:command! -nargs=1 MySQLSetDatabase :call mysql#SetDatabase("<args>")
:command! -nargs=1 MySQLSetTable :call mysql#SetTable("<args>")
:command! -nargs=1 MySQLSetColumn :call mysql#SetColumn("<args>")
