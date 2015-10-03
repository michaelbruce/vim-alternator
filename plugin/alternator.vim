" alternator.vim
" Author:       Michael Bruce <http://focalpointer.org/>
" Version:      0.1
" " map <Leader>5 :unlet g:loaded_alternator<CR>:so %<CR>:echo 'Reloaded!'<CR>

if exists('g:loaded_alternator')
  finish
endif

let g:loaded_alternator = 1

" TODO find the matching file
" TODO workout if you are in a test file or not
" TODO abstract this between languages
" TODO handling same name switches?

" helper functions {{{

" function! s:current_file()
"   return expand("%")
" endf

" }}}

" scenario 1 -
" if current file is ruby,
" then search local directory for <same_name>_spec.rb
"   - if found, switch

function! Alternate()
  if &filetype == 'ruby'
    echo 'yes this is ruby.'
  else
    echo 'this is not ruby.'
  endif
endf

function! FocusOnFile()
  tabnew %
  normal! v
  normal! l
  call OpenTestAlternate()
  normal! h
endfunction

function! s:search_ruby()
  " code
endf

" function! s:in_rails()
"   " code
" endf

" Force.com {{{

function! MatchClassTest()
  let current_file = expand("%")
  if match(current_file, "Test") >= 0
    let new_file = substitute(current_file, 'Test\.cls', '.cls', '')
  else
    let new_file = substitute(current_file, '.cls', 'Test\.cls', '')
  endif
  return new_file
endfunction

" }}}

" vimrc functions {{{

function! OpenTestAlternate()
  let current_file = expand("%") 
  let alternate_file = expand("#")
  let in_app = match(current_file, 'app/') != -1 || match(alternate_file, 'app/') != -1 || match(current_file, 'spec/') != -1
  let in_apex = &filetype == 'apexcode'
  if in_app || in_apex
    if in_apex
      exec ':call OpenApexTest()'
    else
      exec ':A'
    endif
  else
    let new_file = AlternateForCurrentFile() | exec ':e ' . new_file
  end
endfunction

function! AlternateForCurrentFile()
  let current_file = expand("%") | let new_file = current_file | let in_spec = match(current_file, '^spec/') != -1 | let going_to_spec = !in_spec
  let in_app = match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<views\>') != -1 || match(current_file, '\<helpers\>') != -1
  if going_to_spec
    if in_app | let new_file = substitute(new_file, '^app/', '', '')
    end
    let new_file = substitute(new_file, '\.e\?rb$', '_spec.rb', '') | let new_file = 'spec/' . new_file
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '') | let new_file = substitute(new_file, '^spec/', '', '') | if in_app | let new_file = 'app/' . new_file
    end
  endif
  return new_file
endfunction

function! OpenApexTest()
  let new_file = MatchClassTest() | exec ':e ' . new_file
endfunction

" }}}

command! Alternate call Alternate()
command! FocusOnFile call FocusOnFile()
