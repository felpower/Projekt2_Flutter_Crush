using System;
using System.Diagnostics;
using System.Threading.Tasks;
using Debug = UnityEngine.Debug;
public static class SweetShellHelper
{
    public static Task<int> Bash(this string cmd, string fileName)
    {
        var source = new TaskCompletionSource<int>();
        string escapedArgs = cmd.Replace("\"", "\\\"");
        var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = fileName,
                Arguments = $"\"{escapedArgs}\"",
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            },
            EnableRaisingEvents = true
        };
        process.Exited += (sender, args) =>
        {
            Debug.LogWarning(process.StandardError.ReadToEnd());
            Debug.Log(process.StandardOutput.ReadToEnd());
            if (process.ExitCode == 0) {
                source.SetResult(0);
            } else {
                source.SetException(new Exception($"Command `{cmd}` failed with exit code `{process.ExitCode}`"));
            }

            process.Dispose();
        };

        try {
            process.Start();
        }
        catch (Exception e) {
            Debug.LogError(e);
            source.SetException(e);
        }

        return source.Task;
    }
}
