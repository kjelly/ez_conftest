package main
import future.keywords

test_password_auth_yes{
  inputData := {
    "./sshd.py": {
        "words": [

        ["PasswordAuthentication", "yes"]
          ]
      }
  }
  passwordAuth with input as inputData
}

test_password_auth_no{
  inputData := {
    "./sshd.py": {
        "words": [

        ["PasswordAuthentication", "no"]
          ]
      }
  }
  not passwordAuth with input as inputData
}
