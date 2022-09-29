package main
import future.keywords

resource := {
  "kind": "command",
  "command": "cat /etc/fstab",
  "format": "simple",
}

check_mount(path, opts) := true if {
    input["cat /etc/fstab"][i][1] == path
    every o in opts {
      contains(input["cat /etc/fstab"][i][3], o)
    }
} else1 := false


warn_usr[msg]{
  not check_mount("/usr", ["defaults", "nodev", "ro"])
  msg := "usr not ro, nodev"
}

