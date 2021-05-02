if exists("b:did_imgup_ftplugin_markdown")
  finish
endif

let b:did_imgup_ftplugin_markdown = v:true

nnoremap <plug>(imgup-replace) <cmd>lua require'imgup'.replace()<cr>
nnoremap <plug>(imgup-paste) <cmd>lua require'imgup'.put(getreg(v:register))<cr>
