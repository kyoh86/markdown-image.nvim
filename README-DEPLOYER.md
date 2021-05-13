# DEPLOYERS

画像のアップロードを担う各種deployerの説明

## Google Cloud Storage

Google Cloud Storageにアップロードします。

Cloud Storageの設定などはZennの以下記事を参照ください。
https://zenn.dev/kyoh86/articles/3e894d44c8c849f58262

### 使用例

以下のように使用します。

```lua
deployer = require('markdown-image.gcloud').new(host, config, bucket, prefix)
```

| 引数 | 説明 |
| - | - |
| host | アップロードしたバケットにアクセスするホスト名。 |
| config | Google Cloud SDKの構成名。 `gcloud config configurations list` で確認できる |
| bucket | 使用するCloud Storageのバケット名。 |
| prefix | アップロード先のディレクトリ。 |

### 依存

Google Cloud SDK、gsutilsのインストールが必要です。

### 設定例

packer.nvimでの設定例は以下のとおりです

```lua
use {
  'kyoh86/markdown-image.nvim',
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>mir', [[<cmd>lua require('markdown-image').replace(require('markdown-image.gcloud').new('kyoh86.dev', 'post', 'kyoh86.dev', nil))<cr>]], {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>mip', [[<cmd>lua require('markdown-image').put(require('markdown-image.gcloud').new('kyoh86.dev', 'post', 'kyoh86.dev', nil))<cr>]], {noremap = true})
  end,
}
```


## Gyazo

Gyazoにアップロードします。

GyazoのAccess Tokenが必要です。詳細はGyazoのヘルプを参照してください。
https://gyazo.com/api?lang=ja

### 使用例

以下のように使用します。

```lua
deployer = require('markdown-image.gyazo').new(token)
```

| 引数 | 説明 |
| - | - |
| token | GyazoのAccess Token。外部にもれないように注意してください。 |

### 依存

Curlのインストールが必要です。
http://curl.haxx.se/

### 設定例

packer.nvimでの設定例は以下のとおりです

```lua
use {
  'kyoh86/markdown-image.nvim',
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>mir', [[<cmd>lua require('markdown-image').replace(require('markdown-image.gyazo').new('xxxxxxxxxx-xxxxx'))<cr>]], {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>mip', [[<cmd>lua require('markdown-image').put(require('markdown-image.gyazo').new('xxxxxxxxxx-xxxxx'))<cr>]], {noremap = true})
  end,
}
```
