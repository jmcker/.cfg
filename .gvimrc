" VIM configuration
"----------------------
set nocompatible
set exrc " Allow project specific vimrcs
set secure " Prevent unsecure commands in autoloaded vimrcs
filetype on " Prevent spaces when editing Makefiles
autocmd FileType make set noexpandtab shiftwidth=4 softtabstop=0

" UI Settings
"----------------------
colo elflord
set t_Co=256
set background=dark
set whichwrap+=<,>,h,l,[,]
set wildmenu

set cmdheight=2 " Command bar height
set foldcolumn=0 " Add margin on left
set number " Show line numbers
set mouse=a " Enable mouse support for all modes


" Whitespace
"----------------------
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set smartindent
command CleanW %s/\s\+$//e " Trim trailing whitespace


" Syntax & Highlighting
"----------------------
set showmatch " Highlight matching brackets when hovering
set mat=3 " Tenths of a second to show match for
syntax enable " Enable syntax highlighting

" Automatically add closing pairs
ino {<CR> {<CR>}<ESC>O
ino {;<CR> {<CR>};<ESC>O

" Auto Pairs settings
let g:AutoPairsMultilineClose = 0


" Navigation
"----------------------
nnoremap <C-u> :tabnext<CR> 
nnoremap <C-y> :tabprevious<CR>
nnoremap <C-t> :tabnew<CR>
nnoremap <C-w> :tabclose<CR>
nnoremap <C-o> :tabe<Space>
inoremap <C-u> <Esc>:tabnext<CR> 
inoremap <C-y> <Esc>:tabprevious<CR>
inoremap <C-t> <Esc>:tabnew<CR>
inoremap <C-w> <Esc>:tabclose<CR>
inoremap <C-o> <Esc>:tabe<Space>

" Open multiple files in tab view
autocmd VimEnter * tab all

