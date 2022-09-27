package main
import future.keywords

warn_no_source[msg] {
  not input["r snapshots --json"]
  msg := "no restic input. restic tests will be ignored."
}

warn_no_source[msg] {
  not input["pr snapshots --json"]
  msg := "no pr input. restic tests will be ignored."
}

backup_not_found(source, host) := true if {
  date_out := time.date(time.add_date(time.now_ns(), 0, 0, -1))
  yesterday := sprintf("%d-%02d-%d", date_out)
  snapshots := [s | x := input[source][_]
                    x.hostname == host
                    contains(x.time, yesterday)
                    s := x.short_id
                    ]
  count(snapshots) == 0
} else := false

deny_restic_no_backup[msg] {
  input["r snapshots --json"]
  backup_not_found("r snapshots --json", "power")
  msg := sprintf("restic snapshots not found.", [ ])
}

deny_prestic_no_backup[msg] {
  input["pr snapshots --json"]
  backup_not_found("pr snapshots --json", "power")
  msg := sprintf("prestic snapshots not found.", [ ])
}
