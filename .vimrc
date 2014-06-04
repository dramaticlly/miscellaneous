miscellaneous
=============
set nocompatible
"Figure out where my custom settings are stored.

let vimhome = "$HOME/1/"
"let myscriptsfile = vimhome . "/custom/MyScripts.vim"
"exec "source " . vimhome . "/custom/Functions.vim"
"exec "source " . vimhome . "/custom/Abbreviations.vim"
"exec "source " . vimhome . "/custom/MyFileTypes.vim"
"exec "source " . vimhome . "/custom/wordlist.vim"
"exec "source " . vimhome . "/custom/bufexplorer.vim"
"exec "source " . vimhome . "/custom/Comment.vim"

let badMeta = 0

if has("gui_win32")
    set guifont=8x13
elseif has("gui_athena")
    if match( $DISPLAY, "betelgeuse" ) != -1
        set guifont=-adobe-courier-medium-r-normal-*-*-*-100-100-*-*-*-*
    elseif match( $DISPLAY, "trainlab" ) != -1
        set guifont=-adobe-courier-medium-r-*--*-140-100-100-*-*-iso8859-1
    elseif match( $DISPLAY, "landen" ) != -1
        set guifont=-adobe-courier-medium-r-*--*-140-100-100-*-*-iso8859-1
        let badMeta = 1
    elseif match( $DISPLAY, "lily" ) != -1
        set guifont=-misc-fixed-medium-r-normal--20-140-100-100-c-100-iso8859-1
    elseif match( $DISPLAY, "descartes" ) != -1
        set guifont=-misc-fixed-medium-r-normal--20-140-100-100-c-100-iso8859-1
    else
        set guifont=-dec-terminal-medium-r-normal--14-140-75-75-c-8-iso8859-1
    endif
endif

"set guifont=-adobe-courier-medium-r-*--*-95-100-100-*-*-iso8859-1
set guifont=8x13

syntax on
"bs - backspace at start of the line
set bs=2
"sw = shiftwidth
set sw=2
set ts=8
set ruler
set autoindent
set nowrap
"sts = softtabstop - # of spaces used while editing
set sts=8
"et = expand tabs to spaces
"set et
set nowrap
set nohlsearch
set incsearch
"ic - ignore case in search patterns
"set ic
"smart ignore case, no ignore when pattern has uppercase
"set scs
"Store buffer when it's changed and user jumpts to different buffer
set hidden
"nothing is keyword except letters, digits and _
"set iskeyword=1-47,58-64,192-255

"switch to previously edited file
nmap <F1> :e!#<CR>
imap <F1> <ESC>:e!#<CR>
"save file
nmap <F2> :w!<CR>
imap <F2> <ESC>:w!<CR>
"open file
nmap <F3> :e 
nmap <S-F3> :find 
" go to next buffer
nmap <F4> :bprevious!<CR>
" go to previous buffer
nmap <F5> :bnext!<CR>
" go to top/bottom
nmap <F6> 1G
nmap <F7> G
" go to start/end of function
nmap <F8> mp?^{<CR>
nmap <F9> mo/^}<CR>
" inverse wrap on/off
nmap <F10> :set invwrap<CR>
" close buffer/quit
nmap <F11> :bd!<CR>
nmap <F12> :confirm qa<CR>

"List opened buffers
nmap <tab> :buffers<CR>:b
"map S-BS to act same as BS
map! <S-DEL> <BS>

imap <M-p> <C-P>
nmap <M-a> :call Align()<CR>
imap <M-n> <C-N>
imap <M-d> <Del>
"Use CTRL+B to remove a "// " from the beginning of a line when in insert mode.
imap <C-b> <Home><c-o>f/<c-o>"z3x

"Setup Alt + h | j | k | l to move the cursor
imap <M-h> h
imap <M-j> j
imap <M-k> k
imap <M-l> l

" CTRL + up/down moves to the window above or below the current one.
nmap <C-Up> <Up>
nmap <C-Down> <Down>

"Make VIM quiet
set t_vb=""
set vb t_vb=""

"Look in parent directories for tag files
set tags=./tags,tags,../tags,../../tags,../../../tags,../../../../tags,/vbs/engn/cscope/tags
nmap <C-]> g<C-]>
nmap <C-Tab> :ts<CR>

if has("cscope")
    set csprg=/wsdb/oemtools/linuxamd64/bin/cscope-15.5
    set csto=0
    set cst
    set nocsverb
    " add any database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
    " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    set csverb

    """"""""""""" My cscope/vim key mappings
    "
    " The following maps all invoke one of the following cscope search types:
    "
    "   's'   symbol: find all references to the token under cursor
    "   'g'   global: find global definition(s) of the token under cursor
    "   'c'   calls:  find all calls to the function name under cursor
    "   't'   text:   find all instances of the text under cursor
    "   'e'   egrep:  egrep search for the word under cursor
    "   'f'   file:   open the filename under cursor
    "   'i'   includes: find files that include the filename under cursor
    "   'd'   called: find functions that function under cursor calls
    "
    " Below are three sets of the maps: one set that just jumps to your
    " search result, one that splits the existing vim window horizontally and
    " diplays your search result in the new window, and one that does the same
    " thing, but does a vertical split instead (vim 6 only).
    "
    " I've used CTRL-\ and CTRL-@ as the starting keys for these maps, as it's
    " unlikely that you need their default mappings (CTRL-\'s default use is
    " as part of CTRL-\ CTRL-N typemap, which basically just does the same
    " thing as hitting 'escape': CTRL-@ doesn't seem to have any default use).
    " If you don't like using 'CTRL-@' or CTRL-\, , you can change some or all
    " of these maps to use other keys.  One likely candidate is 'CTRL-_'
    " (which also maps to CTRL-/, which is easier to type).  By default it is
    " used to switch between Hebrew and English keyboard mode.
    "
    " All of the maps involving the <cfile> macro use '^<cfile>$': this is so
    " that searches over '#include <time.h>" return only references to
    " 'time.h', and not 'sys/time.h', etc. (by default cscope will return all
    " files that contain 'time.h' as part of their name).


    " To do the first type of search, hit 'CTRL-\', followed by one of the
    " cscope search types above (s,g,c,t,e,f,i,d).  The result of your cscope
    " search will be displayed in the current window.  You can use CTRL-T to
    " go back to where you were before the search.  
    "

    nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>      
    nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>      
    nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>      
    nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>      
    nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>      
    nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>      
    nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
    nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>      


    " Using 'CTRL-spacebar' (intepreted as CTRL-@ by vim) then a search type
    " makes the vim window split horizontally, with search result displayed in
    " the new window.
    "
    " (Note: earlier versions of vim may not have the :scs command, but it
    " can be simulated roughly via:
    "    nmap <C-@>s <C-W><C-S> :cs find s <C-R>=expand("<cword>")<CR><CR>      

    nmap <C-@>s :scs find s <C-R>=expand("<cword>")<CR><CR>     
    nmap <C-@>g :scs find g <C-R>=expand("<cword>")<CR><CR>     
    nmap <C-@>c :scs find c <C-R>=expand("<cword>")<CR><CR>     
    nmap <C-@>t :scs find t <C-R>=expand("<cword>")<CR><CR>     
    nmap <C-@>e :scs find e <C-R>=expand("<cword>")<CR><CR>     
    nmap <C-@>f :scs find f <C-R>=expand("<cfile>")<CR><CR>     
    nmap <C-@>i :scs find i ^<C-R>=expand("<cfile>")<CR>$<CR>   
    nmap <C-@>d :scs find d <C-R>=expand("<cword>")<CR><CR>     


    " Hitting CTRL-space *twice* before the search type does a vertical 
    " split instead of a horizontal one (vim 6 and up only)
    "
    " (Note: you may wish to put a 'set splitright' in your .vimrc
    " if you prefer the new window on the right instead of the left

    nmap <C-@><C-@>s :vert scs find s <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>g :vert scs find g <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>c :vert scs find c <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>t :vert scs find t <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>e :vert scs find e <C-R>=expand("<cword>")<CR><CR>
    nmap <C-@><C-@>f :vert scs find f <C-R>=expand("<cfile>")<CR><CR>   
    nmap <C-@><C-@>i :vert scs find i ^<C-R>=expand("<cfile>")<CR>$<CR> 
    nmap <C-@><C-@>d :vert scs find d <C-R>=expand("<cword>")<CR><CR>
else
    echo "no cscope man"
endif


"Use C indentation rules
set cin
set formatoptions=croqtl1
set tw=80

set comments=sr:/*,mb:*,exl:*/,://
" Use the clipboard by default
set clipboard=unnamed
"Show wild menu
"set wildmenu
set wildmode=longest,list
"Add additional suffixes to the default
set suffixes+=,.class,.swp
"Don't "tab complete" files with these extenstions
set wildignore=*.class,*.swp,*.o
"I never use the menu bar, so this option will disable it
set guioptions-=T
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L
set guioptions-=m
set guioptions+=c

"Regular expressions can't be delimited by letters

:colorscheme torte
"exec "source " . vimhome . "/custom/Watcom_Colors.vim"
":hi Normal          guibg=Black ctermbg=Black       guifg=gray100 ctermfg=grey
":hi Comment                                         guifg=#80a0ff ctermfg=Cyan
":hi PreProc                                         guifg=#ff80ff ctermfg=Yellow 
":hi Type                                            guifg=green ctermfg=White
":hi Constant                                        guifg=Yellow ctermfg=3
":hi Visual          guibg=Yellow ctermbg=Yellow     guifg=#000080 ctermfg=blue
":hi Statement term=bold ctermfg=14 gui=bold guifg=red
":hi Identifier     term=underline ctermfg=3 guifg=cyan

highlight rightMargin term=bold ctermfg=red guifg=red guibg=yellow 
match rightMargin /\%<82v.\%>81v/  

"Set SQC files to behave like c files.
augroup filetypedetect
  au! BufRead,BufNewFile,BufEnter *.SQC		setfiletype c
  au! BufRead,BufNewFile,BufEnter *.dfr		setfiletype diff
augroup END
au BufRead,BufNewFile,BufEnter * set et

function! CleverTab()
   if strpart( getline('.'), col('.')-2, 1 ) =~ '\k'
      return "\<C-P>"
   else
      return "\<Tab>"
endfunction
inoremap <Tab> <C-R>=CleverTab()<CR>

" some useful mappings
:nmap com I/* <ESC>A */<ESC>
:nmap cm ?\/\* <CR>3x/ \*\/<CR>3x
:nmap z<CR> zt

set listchars+=precedes:<,extends:>
set nosol

set path=.,~/build/cur/engn/**,~/build/cur/
set nobackup
set nowritebackup
set diffopt+=context:10
"set diffopt+=iwhite
