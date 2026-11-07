# パッケージ更新

`update` は、このリポジトリで確認済みのバージョンを適用するコマンドです。
実行時に最新版を選び直したり、チェックサムを生成し直したりしません。

```fish
source /path/to/dotfiles/fish/conf.d/custom/update.fish
update --dry-run
update
```

`--dry-run` は更新コマンドを実行せず、適用先と保留対象を表示します。
適用失敗・不正な固定情報は終了コード1、引数の誤りは2を返します。
未導入の管理ツールはスキップし、成功表示と区別します。

## 更新候補の選択

- Aquaのパッケージとレジストリは既存のRenovate連携で更新します。
  `minimumReleaseAge: "7 days"`、`timestamp-required`、`internalChecksFilter: "strict"`
  により、公開日時を取得でき、公開から7日経過した候補だけを提案します。
  Renovateがリポジトリで稼働し、この設定を読み込む必要があります。
- 脆弱性対応も7日待機し、自動マージを無効にしています。緊急修正で例外が
  必要な場合は、修正内容を確認して個別に判断します。
- Fishの`fish_plugins`は完全なコミットSHAで固定します。Tideのv5、SDKMANの
  v2.1.0は同じ参照先をSHAに置き換えました。旧`jorgebucaran/fish-nvm`は
  移転先`jorgebucaran/nvm.fish`に変更しています。
- FishとNeovimのコミット更新は、この設定ではRenovateの自動管理対象ではありません。
  リリース日時・差分を確認してから固定ファイルを更新します。コミット日時は
  公開日時とは異なり、古いコミット日時だけで7日間の公開を保証できません。
  リリースのない更新は、候補SHAを記録してから7日以上保留した上で確認します。

ローカル適用時には公開日時を再取得しません。待機期間は候補選択の段階で守る
運用です。手動で最新バージョンを固定ファイルに書けば、この仕組みを迂回できます。
7日待機は安全性の保証ではなく、既知の悪意ある版や撤回済みの版は除外してください。

## Aqua

`update` は作業ディレクトリに依存せず、このリポジトリの`aqua/aqua.yaml`を
明示してインストールします。チェックサム検証を環境変数でも強制します。
対象はmacOS/Linuxのarm64/amd64です（配布物がない環境では失敗します）。

新しいバージョンを採用するときは、インストールする前にチェックサムを更新して
差分を確認し、`aqua.yaml`と`aqua-checksums.json`を一緒にコミットします。
Renovateのバージョン変更だけではチェックサムが揃わず、適用が失敗する場合があります。

```sh
aqua -c /path/to/dotfiles/aqua/aqua.yaml update-checksum
git diff -- aqua/aqua.yaml aqua/aqua-checksums.json
```

このコマンドは候補の検証時だけ使います。配布元がチェックサムを公開していない
場合は取得した配布物のハッシュになるため、初回取得の正当性を証明するものでは
ありません。同じバージョンのハッシュ変更も自動承認しないでください。

## Fisher / Neovim

Fisherの有効な`fish_plugins`がこのリポジトリのファイルを指していることを確認します。
SHA未指定やタグ指定を含む一覧は拒否します。固定済みプラグインがすべて導入済みなら
再取得しません。Fisherの失敗で固定一覧が書き換わっても、元の一覧を保存します。

Neovimは`-u NONE`で専用スクリプトを実行し、既存のlazy.nvimを使って
`nvim/lua/plugins/lazy-lock.json`のコミットへ復元します。普段の設定やMasonの
自動インストール処理は読み込みません。未導入プラグイン、ビルドフック、LuaRocks
依存の取得は保留します。これらが必要なプラグインは、依存のバージョンや取得元を
別途確認して導入・ビルドしてください。初回導入と未導入プラグインの固定復元には
`python3 scripts/bootstrap-plugins.py`を使います。管理ツール自身もSHA固定し、
`nvim/plugin-sources.json`とlockが一致していることを検査します。
Git/Lazyのエラーと復元後のHEADを検査し、元のlockfileを維持します。

## 保留する管理ツール

Homebrew、Krew、Rustup/Cargo、Go、Volta、pyenv、SDKMAN、Masonの一括更新は
`update`から外しています。代わりの固定一覧がない状態で最新版へ更新しません。

- Go/Cargo製CLIなど、Aquaで管理できるツールは確認済みバージョンをAquaに追加します。
- 言語ランタイムは確認済みの具体的なバージョンを指定して導入します。
  `latest`、`lts`、`stable`などの追従指定は使いません。
- Homebrewは依存パッケージを含む待機期間をこの仕組みでは保証できません。
  自動更新間隔の変更や週1回の実行は、公開から7日待つ設定にはなりません。

Nix本体パッケージは`update-nix`で既存の`home-manager/flake.lock`を適用します。
初回は`bash setup.sh --nix <構成名>`を使います。詳しくは[セットアップ手順](../home-manager/README.md)を参照してください。
これらの適用コマンドは新しいバージョンを選定せず、公開日時の検証も実施しません。
候補を固定ファイルに反映する前に7日待機を確認します。
通常のNeovim起動ではLazyの不足プラグイン取得とMasonの自動導入を停止しました。
`--nix`なしの旧`setup.sh`や各ツールの直接実行は、この固定適用の対象外です。

## 検証

```sh
python3 -m unittest discover -s tests -p 'test_update*.py'
fish --no-config -n fish/conf.d/custom/update.fish
```

テストは一時ディレクトリと代替コマンドで実行し、実際のパッケージを更新しません。
