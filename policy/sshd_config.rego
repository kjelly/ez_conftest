package main
import future.keywords

warn_no_sshd[msg] {
  not input["sshd_config"]
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
  input["sshd_config"][i][0] == "PasswordAuthentication"
  input["sshd_config"][i][1] == "yes"
}

usePAM  {
  input["sshd_config"][j][0] == "UsePAM"
  input["sshd_config"][j][1] == "yes"
}

permitRootLogin  {
  input["sshd_config"][k][0] != "PermitRootLogin"
  input["sshd_config"][k][1] == "yes"
}
