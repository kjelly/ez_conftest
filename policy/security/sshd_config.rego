package main
import future.keywords

resource := {
  "kind": "command",
  "command": "./sshd.py",
  "format": "json",

}

warn_no_sshd[msg] {
  not input["./sshd.py"]
  msg := "no sshd input. sshd tests will be ignored."
}

deny_allow_password_login[msg] {
  passwordAuth
  msg := "allow password to login, password."
} {
  usePAM
  msg := "allow password to login, usePAM."
} {
  permitRootLogin
  msg := "allow password to login, permitRootLogin."
}

passwordAuth {
  input["./sshd.py"][i][0] == "PasswordAuthentication"
  input["./sshd.py"][i][1] == "yes"
}

usePAM  {
  input["./sshd.py"][j][0] == "UsePAM"
  input["./sshd.py"][j][1] == "yes"
}

permitRootLogin  {
  input["./sshd.py"][k][0] != "PermitRootLogin"
  input["./sshd.py"][k][1] == "yes"
}
