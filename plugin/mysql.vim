" TODO SNI: Nur zum Entwickeln
autocmd! BufWritePost /home/snitter/.vim/pack/sni/start/mysql/plugin/mysql.vim source /home/snitter/.vim/pack/sni/start/mysql/plugin/mysql.vim
" autocmd! FileType vim nnoremap <buffer> husten :call mysql#ListDataBases()<cr>
" autocmd! FileType vim nnoremap <buffer> <leader>l :call mysql#ListLoginPathes()<cr>
autocmd! FileType vim call SetUpKeyMaps()

autocmd! FileType sql call SetUpKeyMaps()

:command! -nargs=1 MySQLSetLoginPath :call mysql#SetLoginPath("<args>")
:command! -nargs=1 MySQLSetDatabase :call mysql#SetDatabase("<args>")
:command! -nargs=1 MySQLSetTable :call mysql#SetTable("<args>")
:command! -nargs=1 MySQLSetColumn :call mysql#SetColumn("<args>")

inoremap <leader>d <esc>:call mysql#ListDatabases(v:true)<cr>
inoremap <leader>t <esc>:call mysql#ListTables(v:true)<cr>
inoremap <leader>c <esc>:call mysql#ListColumns(v:true)<cr>

func! SetUpKeyMaps()
    nnoremap <buffer> <leader>l :call mysql#ListLoginPathes()<cr>
    nnoremap <buffer> <leader>d :call mysql#ListDatabases(v:false)<cr>
    nnoremap <buffer> <leader>t :call mysql#ListTables(v:false)<cr>
endfunc
