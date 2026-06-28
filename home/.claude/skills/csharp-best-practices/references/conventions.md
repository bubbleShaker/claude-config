# C# コーディング規約 詳細リファレンス

出典: https://learn.microsoft.com/ja-jp/dotnet/csharp/fundamentals/coding-style/coding-conventions
（最終更新: 2025-01-15）

---

## 文字列データ

短い文字列の連結には文字列補間を使用する。

```csharp
// Good
string displayName = $"{nameList[n].LastName}, {nameList[n].FirstName}";
```

ループ内で大量の文字列を追加する場合は `StringBuilder` を使用する。

```csharp
var phrase = "lalalalalalalalalalalalalalalalalalalalalalalalalalalalalala";
var manyPhrases = new StringBuilder();
for (var i = 0; i < 10000; i++)
{
    manyPhrases.Append(phrase);
}
```

エスケープシーケンスや逐語的な文字列よりも、生の文字列リテラルを推奨する。

```csharp
var message = """
    This is a long message that spans across multiple lines.
    It uses raw string literals. This means we can
    also include characters like \n and \t without escaping them.
    """;
```

位置指定文字列補間ではなく、式ベースの文字列補間を使用する。

```csharp
Console.WriteLine($"{student.Last} Score: {student.score}");
```

---

## コンストラクターと初期化

レコード型のプライマリコンストラクターパラメーターには PascalCase を使用する。

```csharp
public record Person(string FirstName, string LastName);
```

クラス型と構造体型のプライマリコンストラクターパラメーターには camelCase を使用する。

コンストラクターの代わりに `required` プロパティを使用して、プロパティ値の初期化を強制する。

```csharp
public class LabelledContainer<T>(string label)
{
    public string Label { get; } = label;
    public required T Contents
    {
        get;
        init;
    }
}
```

---

## 配列とコレクション

コレクション式を使用してすべてのコレクション型を初期化する。

```csharp
string[] vowels = [ "a", "e", "i", "o", "u" ];
```

---

## デリゲート

デリゲート型を定義する代わりに `Func<>` と `Action<>` を使用する。

```csharp
Action<string> actionExample1 = x => Console.WriteLine($"x is: {x}");
Action<string, string> actionExample2 = (x, y) =>
    Console.WriteLine($"x is: {x}, y is {y}");
Func<string, int> funcExample1 = x => Convert.ToInt32(x);
Func<int, int, int> funcExample2 = (x, y) => x + y;
```

デリゲートのインスタンスを作成する場合、簡潔な構文を使用する。

```csharp
// Good（短縮構文）
Del exampleDel2 = DelMethod;

// 避ける（完全構文）
Del exampleDel1 = new Del(DelMethod);
```

---

## 例外処理（try-catch / using）

ほとんどの例外処理には `try-catch` を使用する。

```csharp
static double ComputeDistance(double x1, double y1, double x2, double y2)
{
    try
    {
        return Math.Sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
    }
    catch (System.ArithmeticException ex)
    {
        Console.WriteLine($"Arithmetic overflow or underflow: {ex}");
        throw;
    }
}
```

`finally` が `Dispose()` の呼び出しのみの場合は `using` ステートメントを使用する。
中かっこなしの新しい `using` 構文を優先する。

```csharp
// Good（新しい using 構文）
using Font normalStyle = new Font("Arial", 10.0f);
byte charset3 = normalStyle.GdiCharSet;

// 避ける（try-finally）
Font bodyStyle = new Font("Arial", 10.0f);
try
{
    byte charset = bodyStyle.GdiCharSet;
}
finally
{
    bodyStyle?.Dispose();
}
```

---

## && 演算子と || 演算子

短絡評価が必要な場合は `&&` / `||` を使用する。
`&` / `|` は両辺を評価するため、意図しない実行時エラーを招く可能性がある。

```csharp
// Good: 短絡評価により divisor == 0 のとき右辺を評価しない
if ((divisor != 0) && (dividend / divisor) is var result)
{
    Console.WriteLine($"Quotient: {result}");
}
```

---

## new 演算子

変数型とオブジェクト型が一致する場合は簡潔な形式を使用する。

```csharp
var firstExample = new ExampleClass();
ExampleClass instance2 = new();
```

オブジェクト初期化子を使用してオブジェクトの作成を簡略化する。

```csharp
// Good
var thirdExample = new ExampleClass { Name = "Desktop", ID = 37414,
    Location = "Redmond", Age = 2.3 };

// 避ける
var fourthExample = new ExampleClass();
fourthExample.Name = "Desktop";
fourthExample.ID = 37414;
fourthExample.Location = "Redmond";
fourthExample.Age = 2.3;
```

---

## イベント処理

後で削除する必要のないイベントハンドラーにはラムダ式を使用する。

```csharp
// Good
this.Click += (s, e) =>
    {
        MessageBox.Show(((MouseEventArgs)e).Location.ToString());
    };

// 避ける
this.Click += new EventHandler(Form1_Click);
```

---

## 静的メンバー

静的メンバーは `ClassName.StaticMember` の形式で呼び出す。
派生クラスの名前を使って基底クラスの静的メンバーを参照しない。

---

## LINQ クエリ

クエリ変数にはわかりやすい名前を使用する。

```csharp
var seattleCustomers = from customer in Customers
                       where customer.City == "Seattle"
                       select customer.Name;
```

匿名型のプロパティ名は PascalCase にする。

```csharp
var localDistributors2 =
    from customer in Customers
    join distributor in Distributors on customer.City equals distributor.City
    select new { CustomerName = customer.Name, DistributorName = distributor.Name };
```

`where` 句を他のクエリ句より先に記述する。

```csharp
var seattleCustomers2 = from customer in Customers
                        where customer.City == "Seattle"
                        orderby customer.Name
                        select customer;
```

`join` よりも複数の `from` 句を優先する。

```csharp
var scoreQuery = from student in students
                 from score in student.Scores
                 where score > 90
                 select new { Last = student.LastName, score };
```

クエリ変数・範囲変数の宣言には暗黙型（`var`）を使用する。

---

## 暗黙的に型指定されるローカル変数（var）

右辺から型が明らかな場合のみ `var` を使用する。

```csharp
// Good: 右辺から型が明らか
var message = "This is clearly a string.";
var currentTemperature = 27;

// 避ける: 右辺から型が不明
int numberOfIterations = Convert.ToInt32(Console.ReadLine());
int currentMaximum = ExampleClass.ResultSoFar();
```

`foreach` のループ変数には `var` を使わず明示的な型を指定する。

```csharp
// Good
foreach (char ch in laugh)
{
    // ...
}
```

`for` ループのループ変数には暗黙型を使用してよい。

```csharp
for (var i = 0; i < 10000; i++)
{
    // ...
}
```

`dynamic` の代わりに `var` を使用しない。

---

## ファイルスコープ名前空間宣言

1ファイルに1名前空間の場合、ファイルスコープの名前空間宣言を使用する。

```csharp
namespace MySampleCode;
```

---

## using ディレクティブの配置

`using` ディレクティブは名前空間宣言の**外側**に配置する。
内側に配置すると、名前解決が状況依存になり予期しないコンパイルエラーを引き起こす可能性がある。

```csharp
// Good
using Azure;

namespace CoolStuff.AwesomeFeature
{
    public class Awesome { ... }
}

// 避ける
namespace CoolStuff.AwesomeFeature
{
    using Azure; // 名前解決が曖昧になる可能性
    public class Awesome { ... }
}
```

---

## スタイルガイドライン

### レイアウト
- インデントはスペース4つ（タブ文字は使わない）
- 1行に1ステートメントのみ
- 1行に1宣言のみ
- 中かっこは Allman スタイル（開きかっこ・閉じかっこをそれぞれ独立した行に）
- メソッド定義・プロパティ定義の間に空白行を1行以上入れる
- 式内の句を明確にするためにかっこを使用する

```csharp
if ((startX > endX) && (startX > previousX))
{
    // Take appropriate action.
}
```

### コメント
- 簡単な説明には `//` を使用する
- `/* */` の複数行コメントは避ける
- パブリックメンバーには XML コメントを使用する
- コメントは独立した行に記述する
- コメントのテキストは大文字で始めてピリオドで終わる
- `//` とコメントテキストの間に空白を1つ入れる

```csharp
// The following declaration creates a query. It does not run
// the query.
```

---

## セキュリティ

安全なコーディングのガイドラインに従う。
参照: https://learn.microsoft.com/ja-jp/dotnet/standard/security/secure-coding-guidelines
