---
name: csharp-best-practices
description: This skill should be used when the user asks to "write C# code", "review C# code", "follow C# coding conventions", "apply C# best practices", "C#のコーディング規約", "C#のベストプラクティス", or when writing, reviewing, or refactoring any C# source file.
---

# C# コーディング規約（.NET 公式ガイドライン）

Apply the following coding conventions from the official Microsoft .NET documentation when writing or reviewing C# code.
For detailed rules and code examples, refer to `references/conventions.md`.

## 言語ガイドライン（重要ルール）

### 型・変数
- `System.String` ではなく `string`、`System.Int32` ではなく `int` など、言語キーワードを優先する
- unsigned 型より `int` を優先する（unsigned 型固有のドキュメントを除く）
- `var` は代入の右辺から型が明らかな場合のみ使用する
- `foreach` のループ変数には `var` を使わず明示的な型を使用する
- `dynamic` の代わりに `var` を使用しない

### 文字列
- 短い文字列の連結には文字列補間（`$"{...}"`）を使用する
- ループ内で大量の文字列を追加する場合は `StringBuilder` を使用する
- エスケープシーケンスより生の文字列リテラル（`""" ... """`）を優先する

### コレクション・配列
- コレクション式（`[ "a", "e", "i" ]`）を使用して初期化する

### デリゲート
- カスタムのデリゲート型定義より `Func<>` / `Action<>` を優先する
- デリゲートのインスタンス化には短縮構文を使用する

### 例外処理
- ほとんどの例外処理には `try-catch` を使用する
- `finally` が `Dispose()` 呼び出しのみの場合は `using` ステートメントを使用する
- 中かっこなしの新しい `using` 構文を優先する

### 論理演算子
- 短絡評価が必要な場合は `&&` / `||` を使用する（`&` / `|` は両辺を評価する）

### new 演算子
- 変数型と一致する場合は `var x = new T()` または `T x = new()` を使用する
- オブジェクト初期化子を活用する

### イベント
- 後で削除しないイベントハンドラーにはラムダ式を使用する

### 静的メンバー
- `ClassName.StaticMember` の形で呼び出す（派生クラス名を使わない）

### LINQ
- クエリ変数には意味のある名前を使用する
- 匿名型のプロパティ名は Pascal ケースにする
- `where` 句を他の句より先に記述する
- `join` より複数の `from` 句を優先する
- クエリ変数・範囲変数には暗黙型（`var`）を使用する

### 名前空間
- ファイルスコープ名前空間宣言（`namespace MyApp;`）を使用する
- `using` ディレクティブは名前空間宣言の**外側**に配置する

## スタイルガイドライン

### コメント
- 簡単な説明には `//` を使用する
- `/* */` の複数行コメントは避ける
- パブリックメンバーには XML コメント（`/// <summary>...`）を使用する
- コメントは独立した行に記述し、大文字で始めピリオドで終わる
- `//` とコメントテキストの間に空白を1つ入れる

### レイアウト
- インデントはスペース4つ（タブ文字は使わない）
- 1行に1ステートメント・1宣言のみ
- 中かっこは Allman スタイル（開きかっこ・閉じかっこをそれぞれ独立した行に）
- メソッド定義・プロパティ定義の間に空白行を1行以上入れる
- 式内の句を明確にするためにかっこを使用する

### 名前規則（コンストラクター）
- レコード型のプライマリコンストラクターパラメーター → PascalCase
- クラス・構造体型のプライマリコンストラクターパラメーター → camelCase
- `required` プロパティを使ってプロパティ値の初期化を強制する

## 参照
- 詳細ルールとコード例: `references/conventions.md`
- 公式ドキュメント: https://learn.microsoft.com/ja-jp/dotnet/csharp/fundamentals/coding-style/coding-conventions
- セキュリティガイドライン: https://learn.microsoft.com/ja-jp/dotnet/standard/security/secure-coding-guidelines
