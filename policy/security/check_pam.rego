package main
import future.keywords

resource := {
  "kind": "command",
  "command": "cat /etc/pam.d/*",
  "format": "simple",
}

warn[msg] {
  not input["cat /etc/pam.d/*"]
  msg := "no pam source"
}


good_pam {
    some i
    input["cat /etc/pam.d/*"][i][1] == "required"
    input["cat /etc/pam.d/*"][i][2] == "pam_lastlog.so"
    input["cat /etc/pam.d/*"][i][3] == "showfailed"
}

deny[msg] {
  not good_pam
  msg := sprintf("%s", [input["cat /etc/pam.d/*"]])

}
