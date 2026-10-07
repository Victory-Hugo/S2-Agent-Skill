$ErrorActionPreference = 'Stop'
$listen = [System.Net.IPAddress]::Any
$lport  = 2222
$target = '10.13.0.20'
$tport  = 2222
$listener = [System.Net.Sockets.TcpListener]::new($listen, $lport)
try {
  $listener.Start()
} catch [System.Net.Sockets.SocketException] {
  # WSAEACCES(10013)：端口被 WSL2/Hyper-V 的 winnat 动态占用，绑定被拒
  Write-Host "[X] 无法监听本地端口 $lport : $($_.Exception.Message)" -ForegroundColor Red
  if ($_.Exception.ErrorCode -eq 10013) {
    Write-Host "    原因：$lport 落在 winnat 的动态排除区间里（开机会漂移）。" -ForegroundColor Yellow
    Write-Host "    长期修复：用管理员 PowerShell 运行一次：" -ForegroundColor Yellow
    Write-Host "      powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\reserve_port.ps1" -ForegroundColor Cyan
    Write-Host "    它会把 $lport 永久预留给本机，重启也有效。" -ForegroundColor Yellow
  }
  Read-Host "按回车退出"
  exit 1
}
Write-Host "RELAY_UP listening :$lport -> ${target}:$tport"
while ($true) {
  try {
    $client = $listener.AcceptTcpClient()
    $remote = [System.Net.Sockets.TcpClient]::new()
    $remote.Connect($target, $tport)
    $cs = $client.GetStream()
    $rs = $remote.GetStream()
    $t1 = $cs.CopyToAsync($rs)
    $t2 = $rs.CopyToAsync($cs)
    [System.Threading.Tasks.Task]::WaitAny(@($t1,$t2)) | Out-Null
    $client.Close(); $remote.Close()
  } catch { Write-Host "ERR $_" }
}
