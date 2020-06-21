# vim-mysql.vim

## Requirements

Needs junegunn/fzf.vim for autocompletion and preview of login-pathes, databases, tables and columns.

## Basic Usage
Make sure, that filetype is sql that is, in normal mode type
`:filetype sql`

Type <leader>l to choose a login-path as definded with `mysql_config_editor`.  
Type <leader>d to choose a database, database name will be inserted at cusor position if <leader>d was typed in insert mode.  
Type <leader>t, equivalent for table.  
Type <leader>c, equivalent for table column, but only in insert mode.  
