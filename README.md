# imgup.nvim

Markdownに置かれた画像を、配置し直すプラグイン。
ついでに、画像を自動で配置して画像として挿入する機能を提供する。

**NOTE: まだ製作中**

## 機能

### `replace(deployer)`

Markdownの画像（すなわち、 `![alt-text](image-url)` ）の上で呼び出すと、
画像のURLまたはファイルパスを取得して、これを適切な場所に配置し直してURLを書き換える。
配置先はdeployerによって変わる。

### `put(deployer)`

指定のレジスタから画像のURLまたはファイルパスを取得して、
これを適切な場所に配置してMarkdownの画像（すなわち、 `![](image-url)` ）として挿入する。

nmapしたキーの前に `"a` のようにレジスタの指定を挟むことで、
デフォルトじゃないレジスタが使える。

## 設定

```lua
vim.api.nvim_set_keymap('n', '<leader>r', [[<cmd>lua require('imgup').replace(deployer)<cr>]], {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>p', [[<cmd>lua require('imgup').put(deployer)<cr>]], {noremap = true})
```

deployerには、以下のインターフェイスを満たすDeployerオブジェクトを指定してください。

```lua
function Deployer.check(self, origin)
  -- check whether the origin is supported or not
  ...
end
function Deployer.deploy(self, path, original)
  -- deploy path and get URL for deployed resource
end
```

## 内蔵Deployer

Deployerを内蔵しています。
現在サポートしているのはGoogle Cloud StorageへのアップロードするDeployerだけです。

### Google Cloud Storage

Google Cloud Storageにアップロードします。

Cloud Storageの設定などはZennの以下記事を参照ください。
https://zenn.dev/kyoh86/articles/3e894d44c8c849f58262

#### 使用例

以下のように使用します。

```lua
deployer = require('imgup.gcloud').new(host, config, bucket, prefix)
```

| 引数 | 説明 |
| - | - |
| host | アップロードしたバケットにアクセスするホスト名。 |
| config | Google Cloud SDKの構成名。 `gcloud config configurations list` で確認できる |
| bucket | 使用するCloud Storageのバケット名。 |
| prefix | アップロード先のディレクトリ。 |

#### 依存

Google Cloud SDK、gsutilsのインストールが必要です。

また、以下2つのLuaRocksに依存します。

- `lua-resty-url`
- `nanoid`

Packer.nvimの`rocks`に指定したりしてください。

```lua
rocks = {
  'lua-resty-url',
  'nanoid',
},
```

#### 設定例

packer.nvimでの設定例は以下のとおりです

```lua
use {
  'kyoh86/imgup.nvim',
  rocks = {
    'lua-resty-url',
    'nanoid',
  },
  config = function()
    vim.api.nvim_set_keymap('n', '<leader>mir', [[<cmd>lua require('imgup').replace(require('imgup.gcloud').new('kyoh86.dev', 'post', 'kyoh86.dev', nil))<cr>]], {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>mip', [[<cmd>lua require('imgup').put(require('imgup.gcloud').new('kyoh86.dev', 'post', 'kyoh86.dev', nil))<cr>]], {noremap = true})
  end,
}
```

## やりたいこと

https://github.com/kyoh86/imgup.nvim/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement

## License

MIT
