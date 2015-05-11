$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Grani_TopShelf : Service" {

    $valid = "Server"
    $validDisplay = "lanmanserver"
    $topShelf = "SampleTopShelfService"
    $topShelfPath = (Resolve-Path ".\SampleTopShelfService\SampleTopShelfService\bin\Debug\SampleTopShelfService.exe").Path
    $invalidTopShelfPath = $topShelfPath + "hogehogmoge"
    $invalid = "server1111111"
    $invalidDisplay = "lanmanserver11111111"

    Context "IsServiceExists" {

        It "IsServiceExists return true for exsisting service." {
            IsServiceExists -Name $valid | Should be $true
        }

        It "IsServiceExists return true for exsisting service." {
            IsServiceExists -Name $validDisplay | Should be $true
        }

        It "IsServiceExists return false for non-exsisting service." {
            IsServiceExists -Name $invalid | Should be $false
        }

        It "IsServiceExists return false for non-exsisting service." {
            IsServiceExists -Name $invalidDisplay | Should be $false
        }
    }

    Context "StartService" {

        It "Start Service should start service." {
            Stop-Service -Name $valid -Force
            (StartService -Name $valid).Status | Should be ([System.ServiceProcess.ServiceControllerStatus]::Running.ToString())
        }        
    }

    Context "StopService" {

        It "Stop Service should stop service." {
            (StopService -Name $valid).Status | Should be ([System.ServiceProcess.ServiceControllerStatus]::Stopped.ToString())
        }        
    }

    Context "GetServiceStatusSafe" {

        It "GetServiceStatusSafe will return null for invalid service." {
            GetServiceStatusSafe -Name $invalid | Should be $null
        }

        It "GetServiceStatusSafe will return Running status for Started service" {
            StartService -Name $valid
            GetServiceStatusSafe -Name $valid | Should be ([System.ServiceProcess.ServiceControllerStatus]::Running.ToString())
        }

        It "GetServiceStatusSafe will return Stopped status for Stopped service" {
            StopService -Name $valid
            GetServiceStatusSafe -Name $valid | Should be ([System.ServiceProcess.ServiceControllerStatus]::Stopped.ToString())
        }
    }
    
    Context "IsServiceRunning" {

        It "IsServiceRunning will return false for invalid service." {
            IsServiceRunning -Name $invalid | Should be $false
        }

        It "IsServiceRunning will return true for Started service" {
            StartService -Name $valid
            IsServiceRunning -Name $valid | Should be $true
        }

        It "IsServiceRunning will return false for Stopped service" {
            StopService -Name $valid
            IsServiceRunning -Name $valid | Should be $false
        }
    }

    Context "IsServiceStopped" {

        It "IsServiceStopped will return false for invalid service." {
            IsServiceStopped -Name $invalid | Should be $false
        }

        It "IsServiceStopped will return false for Started service" {
            StartService -Name $valid
            IsServiceStopped -Name $valid | Should be $false
        }

        It "IsServiceStopped will return true for Stopped service" {
            StopService -Name $valid
            IsServiceStopped -Name $valid | Should be $true
        }
    }

    Context "ValidatePathExists" {

        It "ValidatePathExists should not throw for valid path" {
            {ValidatePathExists -Path $topShelfPath} | Should not Throw
        }

        It "ValidatePathExists should throw for invalid path" {
            {ValidatePathExists -Path $invalidTopShelfPath} | Should Throw
        }
    }

    Context "InstallTopShelfService" {

        It "InstallTopShelfService will success for topshelf service" {
            InstallTopShelfService -Path $topShelfPath
            IsServiceExists -Name $topShelf | Should be $true
        }
    }

    Context "IsTopShelfService" {

        It "IsTopShelfService will return $false for NOT TopShelf Service" {
            IsTopShelfService -Name $valid -Path $topShelfPath | Should be $false
        }

        It "IsTopShelfService will return $true for TopShelf Service which is running" {
            StartService -Name $topShelf
            IsTopShelfService -Name $topShelf -Path $topShelfPath | Should be $true
        }

        It "IsTopShelfService will return $true for TopShelf Service which is Stopped" {
            StopService -Name $topShelf
            IsTopShelfService -Name $topShelf -Path $topShelfPath | Should be $true
        }

        It "IsTopShelfService should reverse service status to Stoppped." {
            IsServiceStopped -Name $topShelf | Should be $true
        }
    }



    Context "UninstallTopShelfService" {

        It "UninstallTopShelfService will success for topshelf service" {
            UninstallTopShelfService -Path $topShelfPath
            IsServiceExists -Name $topShelf | Should be $false
        }
    }
}
