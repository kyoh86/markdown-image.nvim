# imgup.nvim

Markdownに置かれた画像を、Google Cloud Storageにアップロードして、
そこへのリンクに置き換えたいプラグイン。

ついでに、Markdownに画像のパスを貼り付けると、自動でアップロードして、以下略

NOTE: まだ製作中

## 設定

LuaRocksへの依存も含めて、packer.vimでしか検証していません。

```lua
  use {
    '~/Projects/github.com/kyoh86/imgup.nvim',
    rocks = {
      'lua-resty-url',
      'nanoid',
    },
    config = function()
      vim.api.nvim_set_keymap('n', '<leader>mir', '<plug>(imgup-replace)', {})
      vim.api.nvim_set_keymap('n', '<leader>mip', '<plug>(imgup-put)', {})
    end,
  }
```

## アップローダー

現在はGoogle Cloud Storageにのみ対応。

Google Cloud SDK、gsutilsのインストールが必要です。
また、使用するGoogle Cloud SDKの構成名等を設定する必要があります。

```vim
let g:imgup#gcloud#config_name = "..."
let g:imgup#gcloud#bucket_name = "..."
let g:imgup#gcloud#host_name = "..."
let g:imgup#gcloud#prefix = "image"
```

| 設定値 | 意味 |
| -      | -    |
| g:imgup#gcloud#config_name | Google Cloud SDKの構成名。 `gcloud config configurations list` で確認できる |
| g:imgup#gcloud#bucket_name | 使用するCloud Storageのバケット名。 |
| g:imgup#gcloud#host_name | アップロードしたバケットにアクセスするホスト名。 |
| g:imgup#gcloud#prefix | アップロード先のディレクトリ。 |
