# vim-mysql.vim

## Requirements

Needs junegunn/fzf.vim for autocompletion and preview of login-pathes, databases, tables and columns.

## Basic Usage
This plugin lets you select a login-path and a database to execute queries from within vim. Results of SELECT-querie are shown in a scratch buffer.

The login-path is saved by mksession if sessionoptions includes globals. (See :h 'ssop').

Make sure, that filetype is sql that is, in normal mode type
`:filetype sql`

Type `<leader>l` to choose a login-path as definded with `mysql_config_editor`.  
Type `<leader>d` to choose a database, database name will be inserted at cusor position if <leader>d was typed in insert mode.  
Type `<leader>t`, equivalent for table.  
Type `<leader>c`, equivalent for table column, but only in insert mode.  

For executing commands, select them in visual mode, than type `<leader>m`. Note, that only full lines are executed and that a semincolon is needed to seperate them.

Please watch the following gif to see the main functionality. Please note, that my leader key is comma.
The mapping sel<c-j> is not part of this plugin, but a ultisnips snippet:

```
snippet sel
SELECT ${2:*} FROM ${1:tableName}
endsnippet
```

![vimy Demo](demo/vimy.gif)

# Colored output
For colored output in table preview install grc, that is something like `apt install grc`.
