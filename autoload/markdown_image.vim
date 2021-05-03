function! markdown_image#get_image_url() abort
  " Get image URL which the cursor on.
  " @returns: [url, startcol, endcol, line]
  let [l:line, l:col] = searchpairpos('!\[[^\]]*\](', '', ')', 'bcn')
  return matchstr(getline(l:line), '\C\(^!\[[^\]]*\](\)\@<=\([^ )]\+\)\(\( \+=\d\+x\d*\)\?)\)\@=', l:col-1)
endfunction

function! markdown_image#update_image_url(old, new) abort
  let [l:old, l:new] = [escape(a:old, '/\'), escape(a:new, '/\')]
  " update image source
  call execute('%substitute/\C\(!\[[^\]]*\](\)\@<=\V' .. l:old .. '\m\(\( \+=\d\+x\d*\)\=)\)\@=/' .. l:new .. '/g', "silent!")
  " update link ref
  call execute('%substitute/\C\(\(!\)\@<!\[\%([^\]]*\|!\[[^\]]*\]([^)]*)\)\](\)\@<=\V' .. l:old .. '\m\()\)\@=/' .. l:new .. '/g', "silent!")
endfunction
