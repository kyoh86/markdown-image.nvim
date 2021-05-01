if exists("b:did_imgup_ftplugin_markdown")
  finish
endif

let b:did_imgup_ftplugin_markdown = v:true

nmap <plug>(imgup-replace) <cmd>lua require'imgup'.replace()
