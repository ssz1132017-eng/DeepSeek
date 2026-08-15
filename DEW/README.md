# Minimal System (pwsh/read)

A tiny PowerShell-based system with two primitives:

- `pwsh` for execution
- `read` for reading files

Run `./minimal-system.ps1 help` to see the available commands.

Examples:

```powershell
./minimal-system.ps1 read sample.txt
./minimal-system.ps1 pwsh 'Get-Date'
```
