# Capture a screenshot of each theme by switching themes in the terminal,
# rendering the prompt, and snapping the window. Run from inside Windows Terminal.

$ErrorActionPreference = "Stop"

Add-Type -ReferencedAssemblies "System.Drawing.Common","System.Drawing.Primitives" @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public class Cap {
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr h);
    [DllImport("user32.dll")] public static extern int ReleaseDC(IntPtr h, IntPtr dc);
    [DllImport("gdi32.dll")]  public static extern bool BitBlt(IntPtr d,int x,int y,int w,int h,IntPtr s,int sx,int sy,uint op);
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L,T,R,B; }
    public static void Snap(IntPtr hwnd, string path) {
        SetForegroundWindow(hwnd);
        System.Threading.Thread.Sleep(400);
        RECT r; GetWindowRect(hwnd, out r);
        int w = r.R - r.L, h = r.B - r.T;
        var bmp = new Bitmap(w, h);
        var g = Graphics.FromImage(bmp);
        var src = GetDC(IntPtr.Zero);
        var dst = g.GetHdc();
        BitBlt(dst, 0, 0, w, h, src, r.L, r.T, 0x00CC0020);
        g.ReleaseHdc(dst); ReleaseDC(IntPtr.Zero, src); g.Dispose();
        bmp.Save(path, ImageFormat.Png); bmp.Dispose();
    }
}
"@

$wt = Get-Process -Name "WindowsTerminal" | Select-Object -First 1
$shotsDir = "$HOME\dotfiles\screenshots\themes"
New-Item -ItemType Directory -Path $shotsDir -Force | Out-Null

$themes = Get-ChildItem "$HOME\dotfiles\themes\*.omp.json" | Sort-Object Name
foreach ($t in $themes) {
    $name = $t.BaseName -replace '\.omp$',''
    Write-Host "Capturing $name..." -ForegroundColor Cyan
    Clear-Host
    & ([ScriptBlock]::Create((oh-my-posh init pwsh --config $t.FullName)))
    # Render an example prompt + a fake command result so the screenshot is rich
    Write-Host ""
    Start-Sleep -Milliseconds 600
    [Cap]::Snap($wt.MainWindowHandle, "$shotsDir\$name.png")
}

Write-Host "`nDone. Screenshots in $shotsDir" -ForegroundColor Green
