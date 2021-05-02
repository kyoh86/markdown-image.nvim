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

function! imgup#update_image_url(old, new) abort
  let [l:old, l:new] = [escape(a:old, '/\'), escape(a:new, '/\')]
  " update image source
  call execute('%substitute/\C\(!\[[^\]]*\](\)\@<=\V' .. l:old .. '\m\(\( \+=\d\+x\d*\)\=)\)\@=/' .. l:new .. '/g', "silent!")
  " update link ref
  call execute('%substitute/\C\(\(!\)\@<!\[\%([^\]]*\|!\[[^\]]*\]([^)]*)\)\](\)\@<=\V' .. l:old .. '\m\()\)\@=/' .. l:new .. '/g', "silent!")
endfunction
