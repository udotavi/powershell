
BeforeAll {
  . $PSScriptRoot/azure-ad-user-pass.ps1
}

Describe "Abort Function Test" {
  It "Test Case: 1" {
    { Abort } | Should -Throw
  }
}

Describe "Connection Setup Test" {
  Context "Context 0" {
    BeforeEach {
      Mock Connect-AzAccount
      Mock Get-AzAccessToken
      Mock Connect-MgGraph
    }

    It "Test Case: 1" {
      ConnectionSetup | Should -Be $true
    }
  }


  Context "Context 2" {
    BeforeEach {
      Mock Connect-AzAccount { Throw 'Dummy Error' }
    }

    It "Test Case: 1" {
      ConnectionSetup | Should -Be $null
    }
  }

}

Describe "Get User ID Test" {
  Context "Context 0" {
    BeforeEach {
      Mock Get-MgUser -MockWith { [PSCustomObject]@{ Id = 'dummy_id' } }
    }

    It "Test Case: 1" {
      GetAdUserID "dummy_upn" | Should -Be "dummy_id"
    }
  }

  Context "Context 1" {
    BeforeEach {
      Mock Get-MgUser -MockWith { [PSCustomObject]@{ Id = '' } }
    }

    It "Test Case: 1" {
      GetAdUserID "dummy_upn" | Should -Be $null
    }
  }

  Context "Context 2" {
    BeforeEach {
      Mock Get-MgUser { Throw 'Dummy Error' }
    }

    It "Test Case: 1" {
      GetAdUserID "dummy_upn" | Should -Be $null
    }
  }
}

Describe "Get Group ID Test" {
  Context "Context 0" {
    BeforeEach {
      Mock Get-MgGroup -MockWith { [PSCustomObject]@{ Id = 'dummy_id' } }
    }

    It "Test Case: 1" {
      GetAdGroupID "dummy_group_name" | Should -Be "dummy_id"
    }
  }

  Context "Context 1" {
    BeforeEach {
      Mock Get-MgGroup -MockWith { [PSCustomObject]@{ Id = '' } }
    }

    It "Test Case: 1" {
     GetAdGroupID "dummy_group_name" | Should -Be $null
    }
  }

  Context "Context 2" {
    BeforeEach {
      Mock Get-MgGroup { Throw 'Dummy Error' }
    }

    It "Test Case: 1" {
     GetAdGroupID "dummy_group_name" | Should -Be $null
    }
  }
}

Describe "Add Drop Function Test" {
  Context "Context 0" {
    BeforeEach {
      Mock New-MgGroupMember
    }

    It "Test Case: 1" {
      AddDropGroupMember "dummy_group_id" "dummy_user_id" "Add" | Should -Be 0
    }
  }

  Context "Context 1" {
    BeforeEach {
      Mock Remove-MgGroupMemberByRef
    }

    It "Test Case: 1" {
      AddDropGroupMember "dummy_group_id" "dummy_user_id" "Drop" | Should -Be 0
    }
  }

  Context "Context 2" {
    It "Test Case: 1" {
      AddDropGroupMember "dummy_group_id" "dummy_user_id" "WrongAction" | Should -Be 1
    }
  }

  Context "Context 3" {
    BeforeEach {
      Mock Remove-MgGroupMemberByRef { Throw 'Dummy Error' }
    }

    It "Test Case: 1" {
      AddDropGroupMember "dummy_group_id" "dummy_user_id" "Drop" | Should -Be 1
    }
  }
}

Describe "Main Function Test" {
  Context "Context 0" {
    BeforeEach {
      Mock ConnectionSetup {return $true }
      Mock GetAdUserID { return "dummy_id" }
      Mock GetAdGroupID { return "dummy_id" }
      Mock AddDropGroupMember { return 0 }
    }

    It "Test Case: 1" {
      main | Should -Be $true
    }
  }

  # Context "Context 1" {
  #   BeforeEach {
  #     Mock ConnectionSetup {return $false }
  #     Mock GetAdUserID { return $null }
  #     Mock GetAdGroupID { return $null }
  #     Mock AddDropGroupMember { return 1 }
  #   }

  #   It "Test Case: 1" {
  #     main | Should -Throw
  #   }
  # }
}