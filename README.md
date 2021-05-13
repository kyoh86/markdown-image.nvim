# markdown-image.nvim

Markdownに置かれた画像を、配置し直すプラグイン。
ついでに、画像を自動で配置して画像として挿入する機能を提供する。

動画: [![](https://img.youtube.com/vi/exWp_-QIupE/0.jpg)](https://www.youtube.com/watch?v=exWp_-QIupE)

## 機能

### `replace(deployer)`

Markdownの画像（すなわち、 `![alt-text](image-url)` ）の上で呼び出すと、
画像のURLまたはファイルパスを取得して、これを適切な場所に配置し直してURLを書き換える。
配置先はdeployerによって変わる。

### `put(deployer)`

指定のレジスタから画像のURLまたはファイルパスを取得して、
これを適切な場所に配置してMarkdownの画像（すなわち、 `![](image-url)` ）として挿入する。
配置先はdeployerによって変わる。

nmapしたキーの前に `"a` のようにレジスタの指定を挟むことで、
デフォルトじゃないレジスタが使える。

## 設定

mapして使用することをおすすめします。

```lua
vim.api.nvim_set_keymap('n', '<leader>r', [[<cmd>lua require('markdown-image').replace(deployer)<cr>]], {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>p', [[<cmd>lua require('markdown-image').put(deployer)<cr>]], {noremap = true})
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

## 依存

このプラグインは [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) に依存しています。

## 内蔵Deployer

内蔵しているDeployerと設定例の詳細は以下のドキュメントを参照してください。
[README-DEPLOYER.md](README-DEPLOYER.md)

## やりたいこと

https://github.com/kyoh86/markdown-image.nvim/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement

## License

MIT
