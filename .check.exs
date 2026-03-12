# ex_check configuration
# See: mix help check
[
  tools: [
    # Run tests with coverage (enforces 75% minimum via coveralls)
    {:ex_unit, command: "mix test --cover"},
    # Disable doctor/ex_doc - not used in this project
    {:doctor, false},
    {:ex_doc, false},
    # Disable npm_test - no JS tests
    {:npm_test, false},
    # Dialyzer has false positives on ExUnit test support (CaseTemplate, etc)
    {:dialyzer, false},
    # Gettext requires manual `mix gettext.extract` - disable to avoid friction
    {:gettext, false}
  ]
]
