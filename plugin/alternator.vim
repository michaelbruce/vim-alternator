" alternator.vim
" Author:       Michael Bruce <http://focalpointer.org/>
" Version:      0.1
" " map <Leader>5 :unlet g:loaded_alternator<CR>:so %<CR>:echo 'Reloaded!'<CR>

" if exists('g:loaded_alternator')
"   finish
" endif

let g:loaded_alternator = 1

" TODO find the matching file
" TODO workout if you are in a test file or not
" TODO abstract this between languages
" TODO handling same name switches?
" TODO prompt to create file if doesn't exist - http://vim.wikia.com/wiki/User_input_from_a_script

" helper functions {{{

function! s:current_file()
  return expand("%")
endf

function! s:git_root_path()
  return system("cd " . expand('%:p:h') . "&& echo -n $(git rev-parse --show-toplevel)")
endf


function! s:local_file_path()
  return expand('%:h:t') . '/' . expand('%:t')
endf

" }}}

" scenario 1 -
" if current file is ruby,
" then search local directory for <same_name>_spec.rb
"   - if found, switch
"
" scenario 2 - blackjack.rb
" has spec/blackjack.rb relative to original file.
"
" scenario 3 - aggregator base.rb
" lives in app/aggregator but spec is spec/aggregator not spec/app/aggregator
" function to only use single level folder, not whole path from root?

function! Alternate()
  if &filetype == 'ruby'
    call s:switch_ruby()
  elseif &filetype == 'java'
    call s:switch_java()
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

function! s:switch_ruby()
  if s:ruby_is_test()
    call s:ruby_switch_to_target()
  else
    call s:ruby_switch_to_test()
  endif
endf

function! s:ruby_is_test()
  return match(expand('%'), '_spec.rb') != -1
endf

" Switch to test {{{

function! s:ruby_switch_to_test()
  if s:ruby_test_is_local()
    echo 'Found file in same directory'
    exec ':e ' . s:ruby_local_test_file()
  elseif s:ruby_test_is_relative()
    echo 'Found file in relative spec file'
    exec ':e ' . s:ruby_relative_test_file()
  elseif s:ruby_test_is_root_local()
    echo 'Found file in project root (local)'
    exec ':e ' . s:ruby_root_local_test_file()
  elseif s:ruby_test_is_root_relative()
    echo 'Found file in project root (relative)'
    exec ':e ' . s:ruby_root_relative_test_file()
  elseif s:ruby_test_is_root_single_relative()
    echo 'Found file in project root (single)'
    exec ':e ' . s:ruby_root_single_relative_test_file()
  else
    echo 'Test file not found'
  endif
endf

function! s:ruby_test_is_local()
  return filereadable(s:ruby_local_test_file())
endf

function! s:ruby_local_test_file()
  return substitute(expand('%'), '\.e\?rb$', '_spec.rb', '')
endf

function! s:ruby_test_is_relative()
  return filereadable(s:ruby_relative_test_file())
endf

function! s:ruby_relative_test_file()
  return expand('%:h') . '/spec/' . substitute(expand('%:t'), '\.e\?rb$', '_spec.rb', '')
endf

function! s:ruby_test_is_root_local()
  return filereadable(s:ruby_root_local_test_file())
endf

function! s:ruby_root_local_test_file()
  return s:git_root_path() . '/spec/' . substitute(expand('%:t'), '\.e\?rb$', '_spec.rb', '')
endf

function! s:ruby_test_is_root_relative()
  return filereadable(s:ruby_root_relative_test_file())
endf

function! s:ruby_root_relative_test_file()
  let root = s:git_root_path()
  let git_local_file_path = substitute(expand('%:p'), root, '', '')
  return root . '/spec' . substitute(git_local_file_path, '\.e\?rb$', '_spec.rb', '')
endf

function! s:ruby_test_is_root_single_relative()
  return filereadable(s:ruby_root_single_relative_test_file())
endf

function! s:ruby_root_single_relative_test_file()
  return s:git_root_path() . '/spec/' . substitute(s:local_file_path(), '\.e\?rb$', '_spec.rb', '')
endf

" }}}

" Switch to target {{{

function! s:ruby_switch_to_target()
  " is test in spec folder?
  if s:ruby_test_in_test_folder()
    echo 'Test is in test folder'
    " if git root, go there
    " if not go relative
  else
    echo 'This is a test file'
  endif
endf

function! s:ruby_target_is_root_relative()
  " e.g y/x/target.rb from spec/y/x/test.rb
  " code
endf

function! s:ruby_root_single_relative_target_file()
  return s:git_root_path() . '/' . substitute(s:local_file_path(), '_spec.rb', '', '')
endf

" function! s:ruby_is_test_folder_relative()
"   echo 'hiii'
" endf

" a.k.a is target relative?
function! s:ruby_test_in_test_folder()
  return match(expand('%'), '/spec/') != -1
endf

" }}}

function! s:wip_switch_ruby()
  echo 'switching to test'
  let current_file = expand("%")
  let new_file = current_file
  let in_spec = match(current_file, '^spec/') != -1
  let going_to_spec = !in_spec

  let in_app = match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<views\>') != -1 || match(current_file, '\<helpers\>') != -1

  if going_to_spec
    if in_app | let new_file = substitute(new_file, '^app/', '', '')
    end
    let new_file = substitute(new_file, '\.e\?rb$', '_spec.rb', '') | let new_file = 'spec/' . new_file
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '') | let new_file = substitute(new_file, '^spec/', '', '') | if in_app | let new_file = 'app/' . new_file
    end
  endif
  " return new_file
  exec ':e ' . new_file
endf

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

" Java {{{

function! s:switch_java()
  let current_file = expand("%")
  if match(current_file, "Test") >= 0
    let new_file = substitute(current_file, 'Test\.java', '\.java', '')
    let new_file = substitute(new_file, 'test/', 'main/', '')
  else
    let new_file = substitute(current_file, '\.java', 'Test\.java', '')
    let new_file = substitute(new_file, 'main/', 'test/', '')
  endif
  exec ':e ' . new_file
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
