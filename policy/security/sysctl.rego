package main
import future.keywords

resource := {
  "kind": "command",
  "command": "sysctl -a",
  "format": "simple",
}

deny[msg] {
  input["sysctl -a"][i][0] == "net.ipv4.tcp_syncookies"
  input["sysctl -a"][i][2] != "1"
  msg := "bad tcp_syncookies"
}{
  input["sysctl -a"][i][0] == "kernel.kptr_restrict"
  input["sysctl -a"][i][2] != "1"
  msg := "bad kptr_restrict"
}{
  input["sysctl -a"][i][0] == "kernel.exec-shield"
  input["sysctl -a"][i][2] != "2"
  msg := "bad exec-shield"
}{
  input["sysctl -a"][i][0] == "kernel.randomize_va_space"
  input["sysctl -a"][i][2] != "2"
  msg := "bad randomize_va_space"
}{
  input["sysctl -a"][i][0] == "kernel.dmesg_restrict"
  input["sysctl -a"][i][2] != "1"
  msg := "bad dmesg_restrict"
}
