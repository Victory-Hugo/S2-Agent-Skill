# 一次性把本地端口持久化预留给 relay，避免 WSL2/Hyper-V 的 winnat 动态占用导致绑定失败
# 用法（管理员 PowerShell）：powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\reserve_port.ps1
# 幂等：已预留则跳过；重启后依然有效（store=persistent）。
$port = 2222

function Test-Admin {
  $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  (New-Object System.Security.Principal.WindowsPrincipal($id)).IsInRole(
    [System.Security.Principal.WindowsBuiltInRole]::Administrator)
}
if (-not (Test-Admin)) {
  Write-Host "[!] 需要管理员权限。请用管理员 PowerShell 重新运行本脚本。" -ForegroundColor Red
  Read-Host "按回车退出"
  exit 1
}

Write-Host "[*] 当前 TCP 排除区间："
netsh int ipv4 show excludedportrange protocol=tcp

Write-Host "`n[*] 停止 winnat 以释放动态占用..."
net stop winnat 2>$null | Out-Null

Write-Host "[*] 持久化预留 TCP $port ..."
netsh int ipv4 add excludedportrange protocol=tcp startport=$port numberofports=1 store=persistent | Out-Null

Write-Host "[*] 重新启动 winnat ..."
net start winnat 2>$null | Out-Null

Write-Host "`n[*] 预留后的 TCP 排除区间（应能看到 $port 被单独/持久预留）："
netsh int ipv4 show excludedportrange protocol=tcp

Write-Host "`n[OK] 完成。之后直接运行 relay.ps1 即可，端口 $port 永久可用。" -ForegroundColor Green
Read-Host "按回车退出"
