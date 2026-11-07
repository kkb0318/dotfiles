# Nix Flakes の更新と採用前の待機

## 採用方針

目的はサプライチェーン攻撃などの問題が判明するまでの猶予を作ること。
厳密な公開後168時間・過去の適格リビジョンの探索は取り下げ、
**週1回の更新PR + PRの内容を72時間保留 + 3環境のビルド**を採用する。
独自の公開日時データベースは作らない。待機やCI成功は安全性そのものを保証しない。

## 対象と Renovate

| input | 追跡対象 |
|---|---|
| nixpkgs | `nixos/nixpkgs` の `nixos-unstable` |
| home-manager | `nix-community/home-manager` の既定ブランチ |

Home Manager の nixpkgs は root の nixpkgs を follows する。
Renovate Nix Manager が `flake.nix` を検出し、Lock File Maintenance が
`flake.lock` 更新PRを作る。Nix限定で月曜午前6時前（Asia/Tokyo）を指定する。
これはRenovateを起動する設定ではなく、インストール済みRenovateの処理窓。

[git-refs](https://docs.renovatebot.com/modules/datasource/git-refs/) は公開日時を提供せず、
[Nixのlock更新](https://docs.renovatebot.com/modules/manager/nix/) はNixに委譲される。
Nixのみ `minimumReleaseAge: "0 days"` として日時不明による永久保留を避け、
待機をCIで実施する。他managerの7日設定・自動マージ設定は変更しない。
Nixの自動マージは導入段階では無効。不要なリベースを抑えるため
`rebaseWhen: conflicted` とし、スケジュール外の更新を無効にする。

## 待機の動作

1. PRの `flake.nix` / `flake.lock` の変更を検出する（改名も含む）。
2. GitHub APIのworkflow run `created_at` から72時間待つ。
   コミット日時やlockの `lastModified` は使わない。
3. 期限前は `Nix cooldown` が意図的に失敗し、実行概要に期限を表示する。
   Nixビルドはまだ実行しない。
4. 毎日06:23 UTC（15:23 JST）の `Recheck Nix cooldown` が開いているPRの現在のSHAに
   対応する最新の実行を調べ、期限後に待機ジョブとその依存ジョブを再実行する。
   再実行では同じrunの作成時刻を使う。GitHubの混雑で実行が遅れる場合がある。
5. 追加コミット・リベースは新しいrunになるため待機を再開する。
   PR自体が古くても新しい内容を即採用しない。コメントだけではリセットしない。

期限後はmacOS ARM / Intel・Linux x86_64で社用・私用のactivationPackageをビルドする。
lockの書き換えは禁止。実機への設定適用は行わない。
全ビルド・待機・単体テストの成功時のみ集約チェック `Nix CI` が成功する。
他の依存だけのPRにはNixの待機を追加しない。

## 導入・運用

- デフォルトブランチへ取り込むと定期workflowが有効になる。
- GitHubのruleset / branch protectionで **`Nix CI` を必須チェック**にする。
  workflowの追加だけではマージを禁止できない。CI設定・判定スクリプトの変更もレビューする。
- Renovateが月曜の窓内に稼働し、Nixの更新PRを作ることを確認する。
- 最初のPRで待機→自動再チェック→3環境成功を確認してから、必要ならNixの自動マージを有効にする。

待機中は意図的な失敗表示になり、概要に期限が表示される。APIエラー・日時不明は承認しない。
ビルド失敗は別ジョブで表示され、自動で繰り返し再試行しない。
更新失敗はRenovate Dependency DashboardとPR、定期処理の失敗はActionsで確認する。
通知を受け取るにはGitHubのActions通知設定を有効にする。
30日以上経過したrunは再実行期限切れとして警告を出す。新しいコミットで再開する
（その場合は待機も再開する）。定期処理はPRのコードを実行せず、デフォルトブランチの
スクリプトのみをActions書き込み権限で実行する。

緊急の脆弱性対応は自動マージせず、対象SHA・理由をPRに記録して管理者が承認する。
待機短縮が必要なら管理者がrulesetの例外を監査可能な手順で扱い、各環境のビルドを別途確認する。
ラベルによる自動的な待機回避は設けない。

ローカルの `update-nix` はlockを適用するだけで待機を検証しない。
通常はマージ済みlockを適用する。未マージPRのローカル適用は待機を迂回する。
Nixpkgs内の個別パッケージの公開日時や、待機中の脆弱性検出は保証対象外。

## 検証

```sh
node --test tests/test_nix_cooldown.cjs
python3 -m unittest discover -s tests -p 'test_*.py'
```

単体テストは72時間境界、追加コミット、古いSHA、日時不明、他manager除外、改名、
API失敗、自動再実行、ビルド失敗の再試行抑止を検証する。
GitHub上の実API呼び出し・定期実行・3環境の実ビルド・マージ禁止は導入後の確認が必要。
