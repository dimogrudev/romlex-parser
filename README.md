# ROMLEX Parser
A PowerShell parser of ROMLEX Lexical Database.

## What Is ROMLEX?
ROMLEX is a lexical database of Romani language. It contains representative data of lexicon variation of all Romani dialects, and offers almost complete coverage of basic lexicon of the language.

## How to Use
1. Open `parser.ps1` with a source code editor.
2. Set the output directory by changing the following variable:
```powershell
$output = "D:\GitHub\romlex-parser\dictionaries";
```
3. Save changes and execute the script with PowerShell.

The script saves parsed dictionaries in CSV-files using the path `\(dialect)\(translation).csv`.
