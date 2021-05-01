function! imgup#get_image_url() abort
  " Get image URL which the cursor on.
  " @returns: [url, startcol, endcol, line]
  let [l:line, l:col] = searchpairpos('!\[[^\]]*\](', '', ')', 'bcn')
  let [l:str, l:start_col, l:end_col] = matchstrpos(getline(l:line), '\C\(^!\[[^\]]*\](\)\@<=\([^ )]\+\)\(\( \+=\d\+x\d*\)\?)\)\@=', l:col-1)
  if l:start_col == -1 || l:end_col == -1
    return []
  else
    return [l:str, l:start_col, l:end_col, line('.')]
  endif
endfunction

function! imgup#set_image_url(old, new) abort
  call execute('%substitute/\C\(!\=\[[^\]]*\](\)\@<=\V' .. a:old .. '\m\(\( \+=\d\+x\d*\)\=)\)\@=/' .. escape(a:new, '/\') .. '/g')
endfunction
