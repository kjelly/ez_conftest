package main
import future.keywords

resource := {
  "kind": "command",
  "command": "ps aux",
  "format": "simple",
}

warn[msg] {
  not input["ps aux"]
  msg := "no process input. sshd tests will be ignored."
}

deny_neovim_use_too_memory[msg] {
  neovim := [x | y := input["ps aux"][_]
                 contains(y[10], "nvim")
                 x := to_number(y[3])]
  sum(neovim) > 5
  msg := sprintf("neovim process %f %%", [sum(neovim)])
}
