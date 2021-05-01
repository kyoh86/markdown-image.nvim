function imgup#get_image_url() abort
  " Get image URL which the cursor on.
  " @returns: [url, startcol, endcol, line]
  let [l:line, l:col] = searchpairpos('!\[[^\]]*\](', '', ')', 'bcn')
  let [l:str, l:start_col, l:end_col] = matchstrpos(getline(l:line), '\(^!\[[^\]]*\](\)\@<=\([^ )]\+\)\(\( \+=\d\+x\d*\)\?)\)\@=', l:col-1)
  if l:start_col == -1 || l:end_col == -1
    return []
  else
    return [l:str, l:start_col, l:end_col, line('.')]
  endif
endfunction
